module Lua
  abstract class Object
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
end

require "./object/*"
