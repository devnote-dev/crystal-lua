module Lua
  private class Base
    @state : State
    getter! ref : Int32

    def initialize(@state : State, @ref : Int32?)
    end

    protected def preload(state : State = @state, & : Int32 -> _)
      ensure_reference!
      LibLua.rawgeti(state, -1_001_000, ref)
      yield state.size
    ensure
      state.remove
    end

    protected def ensure_reference! : Nil
      return if ref? && ref > 0
      raise RuntimeError.new "Object does not have a valid reference in the registry"
    end
  end

  class Function < Base
    def call(*args : Any::Type) : Any?
      preload do |_|
        args.each { |arg| @state.push arg }
        @state.protected_call args.size, 1, 0
        @state.pop
      end
    end
  end

  class Table < Base
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

    def []=(index : Any::Type, value : Any::Type) : Any::Type
      preload do |pos|
        @state.push index
        @state.push value
        LibLua.settable(@state, pos)
      end

      value
    end

    def to_h : Hash(Any, Any)
      each_with_object({} of Any => Any) do |(key, value), obj|
        obj[key] = value
      end
    end
  end
end
