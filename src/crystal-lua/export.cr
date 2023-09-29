module Lua
  annotation Export
  end

  macro export_function(state, name, &block)
    {% name.raise "expected argument #2 to be a string literal" unless name.is_a?(StringLiteral) %}
    proc = ->(ptr : LibLua::State) do
      %state = Lua::State.new ptr
      {% unless block.args.empty? %}
        {% for arg, index in block.args %}
          {{ arg }} = %state.index!(-{{ index + 1 }})
        {% end %}
      {% end %}
      begin
        result = begin
          {{ block.body }}
        end
        %state.push result
      rescue ex
        %state.error ex.to_s, nil
      end
      1
    end

    {{ state }}.push proc
    {{ state }}.set_global {{ name }}
  end
end
