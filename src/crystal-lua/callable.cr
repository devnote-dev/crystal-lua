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

      macro finished
        {% begin %}
          {% methods = @type.methods.select &.annotation(Lua::Export) %}
          {% for method in methods %}
            {% method.raise "cannot export an abstract method" if method.abstract? %}
            {% method.raise "cannot yield to the Lua runtime" if method.accepts_block? %}
            {% for arg in method.args %}
              {% if arg.restriction && arg.restriction.class_name != "Lua::Any" %}
                {% arg.raise "method arguments must be of type Lua::Any" %}
              {% end %}
            {% end %}
            {% if method.return_type.is_a?(Nop) %}
              {% method.raise "a return type must be specified" %}
            {% end %}
            {% type_name = method.return_type.class_name %}
            {% unless %w[Nil Bool String].includes?(type_name) %}
              {% unless type_name.starts_with?("Int") ||
                          type_name.starts_with?("UInt") ||
                          type_name.starts_with?("Float") ||
                          type_name.starts_with?("Array") ||
                          type_name.starts_with?("Hash") %}
                {% method.return_type.raise "cannot use #{return_type} as a return type" %}
              {% end %}
            {% end %}
          {% end %}
          def __index(key : String)
            case key
            {% for method in methods %}
            when {{ method.name.stringify }}
              return self.{{ method.name }}
            {% end %}
            else
              __call(key)
            end
          end

          def __newindex(key : String, value : Lua::Any)
            {% setters = methods.select &.ends_with?('=') %}
            case key
            {% for method in setters %}
            when {{ method.name.stringify }}
              self.{{ method.name }} = value
            {% end %}
            end
          end

          def __call(key : String)
            case key
            {% for method in methods %}
            when {{ method.name.stringify }}
              return ->(ptr : LibLua::State) do
                state = Lua::State.new ptr
                {% for arg in method.args %}
                  {{ arg }} = state.index!(-{{ index + 1 }})
                {% end %}
                result = self.{{ method.name }}({% for arg in method.args %}{{ arg }},{% end %})
                state.push result
                1
              end
            {% end %}
            end
          end
        {% end %}
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
      data = LibLua.topointer(state, -1_001_000 - 1)
      ptr = LibLua.topointer(state, -1_001_000 - 2)
      proc = Proc(LibLua::State, Int32).new(ptr, data)

      proc.call(state)
    end
  end
end
