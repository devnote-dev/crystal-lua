module Lua
  module Callable
    macro included
      def self.__new(ptr : LibLua::State) : Int32
        state = Lua::State.new ptr
        instance = allocate

        instance.initialize
        GC.add_finalizer(instance) if instance.responds_to?(:finalize)
        state.push instance

        1
      end

      macro inherited
        def self.__new(ptr : LibLua::State) : Int32
          super
        end
      end

      macro method_added(method)
        \{%
          if method.annotation(::Lua::Export)
            method.raise "cannot export an abstract method" if method.abstract?
            method.raise "cannot yield to the Lua runtime" if method.accepts_block?

            method.args.each do |arg|
              if arg.restriction && arg.restriction.resolve != ::Lua::Any
                arg.raise "method argments must be ::Lua::Any, not #{arg.restriction}"
              end
            end

            if method.return_type.is_a?(Nop)
              method.raise "a return type must be specified"
            end

            type = method.return_type.resolve
            unless ::Lua::Any::Type.union_types.includes?(type)
              method.return_type.raise "cannot use #{type} as a return type"
            end
          end
        %}
      end

      macro finished
        def __index(key : String)
          case key
          \{% for ivar in @type.instance_vars %}
            \{% if @type.has_method?(ivar.name) %}
            when \{{ ivar.name.stringify }}
              return self.\{{ ivar.name }}
            \{% end %}
          \{% end %}
          else
            __call(key)
          end
        end

        def __newindex(key : String, value : Lua::Any)
          case key
          \{% for ivar in @type.instance_vars %}
            \{% if @type.has_method?(ivar.name + "=") %}
            when \{{ ivar.name.stringify }}
              self.\{{ ivar.name }} = value.raw.as(\{{ ivar.type }})
            \{% end %}
          \{% end %}
          else
            __call(key)
          end
        end

        def __call(key : String)
          p! key
          case key
          \{% for method in @type.methods %}
            when \{{ method.name.stringify }}
              return ->(ptr : LibLua::State) do
                %state = Lua::State.new ptr
                \{% for arg, index in method.args %}
                  \{{ arg.name }} = %state.index!(-\{{ index + 1 }})
                \{% end %}
                %result = self.\{{ method.name }}(\{% for arg in method.args %}\{{ arg.name }},\{% end %})
                %state.push %result
                1
              end
          \{% end %}
          end
        end
      end
    end

    def self.__index(ptr : LibLua::State) : Int32
      state = State.new ptr
      key = state.to_string -1
      data = state.to_userdata(-2, Callable)
      data.__index(key)

      1
    end

    def self.__newindex(ptr : LibLua::State) : Int32
      state = State.new ptr
      data = state.to_userdata(-3, Callable)

      value = state.index! -1
      key = state.to_string -2
      data.__newindex(key, value)

      0
    end

    def self.__gc(ptr : LibLua::State) : Int32
      0
    end

    def self.__call(state : LibLua::State) : Int32
      data = LibLua.topointer(state, REGISTRY_INDEX - 1)
      ptr = LibLua.topointer(state, REGISTRY_INDEX - 2)
      proc = Proc(LibLua::State, Int32).new(ptr, data)

      proc.call(state)
    end
  end
end
