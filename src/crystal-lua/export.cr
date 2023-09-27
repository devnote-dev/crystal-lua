module Lua
  annotation Export
  end

  alias ExportType = Nil | Bool | Number::Primitive | String | Array(ExportType) | Hash(ExportType, ExportType)

  macro export_function(state, name, &block)
    {% name.raise "expected argument #2 to be a string literal" unless name.is_a?(StringLiteral) %}
    proc = ->(st : LibLua::State) do
      func = ->(
        {% for arg in block.args %}
          {{ arg }} : Lua::Any,
        {% end %}
      ) : Lua::ExportType do
        {{ block.body }}
      end

      state = Lua::State.new st
      {% if block.args.empty? %}
        result = func.call
      {% else %}
        {% for arg, index in block.args %}
          {{ arg }} = state.index!(-{{ index + 1 }})
        {% end %}
        result = func.call({% for arg in block.args %}{{ arg }},{% end %})
      {% end %}
      state.push result
      1
    end

    # {{ state }}.push proc
    LibLua.pushcclosure({{ state }}, proc, 0)
    {{ state }}.set_global {{ name }}
  end

  def self.__call(state : LibLua::State) : Int32
    data = LibLua.topointer(state, -1_001_000 - 1)
    ptr = LibLua.topointer(state, -1_001_000 - 2)
    proc = Proc(LibLua::State, Int32).new(ptr, data)

    proc.call(state)
  end
end
