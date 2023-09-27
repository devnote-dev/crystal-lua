module Lua
  class Table < Lua::Object
    include Enumerable({Any, Any})

    def each(& : {Any, Any} ->)
      preload do |pos|
        @state.push nil

        while @state.next pos
          key = @state.index!(-2)
          value = @state.index!(-1)

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
