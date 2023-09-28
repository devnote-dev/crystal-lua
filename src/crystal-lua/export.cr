module Lua
  annotation Export
  end

  macro export_function(state, name, &block)
    {% name.raise "expected argument #2 to be a string literal" unless name.is_a?(StringLiteral) %}
    proc = ->(st : LibLua::State) do
      %state = Lua::State.new st
      {% unless block.args.empty? %}
        {% for arg, index in block.args %}
          {{ arg }} = %state.index!(-{{ index + 1 }})
        {% end %}
      {% end %}
      result = begin
        {{ block.body }}
      end
      %state.push result
      1
    end

    {{ state }}.push proc
    {{ state }}.set_global {{ name }}
  end

  def self.__call(state : LibLua::State) : Int32
    data = LibLua.topointer(state, -1_001_000 - 1)
    ptr = LibLua.topointer(state, -1_001_000 - 2)
    proc = Proc(LibLua::State, Int32).new(ptr, data)

    proc.call(state)
  end

  def self.__gc(state : LibLua::State) : Int32
    0
  end
end
