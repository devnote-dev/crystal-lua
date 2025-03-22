module Lua
  annotation Export
  end

  abstract class Object
    class_getter class_methods = {} of String => LibLua::CFunction
    class_getter instance_methods = {} of String => LibLua::CFunction
    class_property metatable : String { self.name }

    macro inherited
      macro method_added(method)
        \{% if method.annotation(::Lua::Export) %}
          \{% if method.name == "initialize" %}
            %proc = ->(ptr : LibLua::State) : Int32 do
              %state = Lua::State.new ptr

              \{% unless method.args.empty? %}
                \{% for _, index in method.args %}
                  \{% arg = method.args[-(index + 1)] %}
                  \{{arg.name}} = %state.index!(-\{{index + 1}})
                \{% end %}
              \{% end %}

              begin
                instance = self.new(\{% for arg in method.args %}\{{arg.name}},\{% end %})
                %state.push instance
              rescue ex
                %state.error ex.to_s, nil
              end

              1
            end

            class_methods["new"] = %proc
          \{% else %}
            %proc = ->(ptr : LibLua::State) : Int32 do
              %state = Lua::State.new ptr

              \{% unless method.args.empty? %}
                \{% for _, index in method.args %}
                  \{% arg = method.args[-(index + 1)] %}
                  \{{arg.name}} = %state.index!(-\{{index + 1}})
                \{% end %}
              \{% end %}

              begin
                %state.push self.\{{method.name}}(\{% for arg in method.args %}\{{arg.name}},\{% end %})
              rescue ex
                %state.error ex.to_s, nil
              end

              1
            end

            instance_methods[\{{method.name.stringify}}] = %proc
          \{% end %}
        \{% end %}
      end

      def __index(ptr : LibLua::State, key : String)
        self.class.instance_methods[key]?.try &.call(ptr)
      end
    end

    macro def_class_method(name, &block)
      {% name.raise "expected argument #2 to be a string literal" unless name.is_a?(StringLiteral) %}
      %proc = ->(ptr : LibLua::State) : Int32 do
        %state = Lua::State.new ptr

        {% unless block.args.empty? %}
          {% for arg, index in block.args %}
            {{arg}} = %state.index!(-{{index + 1}})
          {% end %}
        {% end %}

        begin
          result = begin
            {{block.body}}
          end
          %state.push result
        rescue ex
          %state.error ex.to_s, nil
        end

        1
      end
    end

    def self.__call(state : LibLua::State) : Int32
      data = LibLua.topointer(state, REGISTRY_INDEX - 1)
      ptr = LibLua.topointer(state, REGISTRY_INDEX - 2)
      proc = Proc(LibLua::State, Int32).new(ptr, data)

      proc.call(state)
    end

    def self.__gc(state : LibLua::State) : Int32
      0
    end

    def self.__index(ptr : LibLua::State) : Int32
      state = State.new ptr
      key = state.to_string -1
      data = state.to_userdata(-2, Lua::Object)
      data.__index(ptr, key)

      1
    end
  end

  macro create_function(state, name, &block)
    {% name.raise "expected argument #2 to be a string literal" unless name.is_a?(StringLiteral) %}
    %proc = ->(ptr : LibLua::State) : Int32 do
      %state = Lua::State.new ptr

      {% unless block.args.empty? %}
        {% for arg, index in block.args %}
          {{arg}} = %state.index!(-{{index + 1}})
        {% end %}
      {% end %}

      begin
        result = begin
          {{block.body}}
        end
        %state.push result
      rescue ex
        %state.error ex.to_s, nil
      end

      1
    end

    {{state}}.push %proc
    {{state}}.set_global {{name}}
  end
end
