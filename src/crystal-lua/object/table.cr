module Lua
  class Table < Lua::Object
    include Enumerable({Any, Any})

    def each(& : {Any, Any} ->)
      preload do |pos|
        @state.push_nil

        until LibLua.next(@state, pos) == 0
          key = @state.index(-2).as(Any)
          value = @state.index(-1).as(Any)

          yield({key, value})
          @state.remove
        end
      end
    end

    def [](index : Any::Type) : Any?
      preload do |pos|
        @state.push index
        LibLua.gettable(@state, pos)
        @state.pop
      end
    end

    def []=(index : Any::Type, value : Any::Type)
      preload do |pos|
        @state.push index
        @state.push value
        LibLua.settable(@state, pos)
      end
    end

    def to_h : Hash(Any, Any)
      each_with_object({} of Any => Any) do |(key, value), obj|
        obj[key] = value
      end
    end
  end
end
