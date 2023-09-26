module Lua
  class State
    def push(value : Bool) : Nil
      LibLua.pushboolean(@state, value)
    end

    def push(value : Proc) : Nil
      if value.closure?
        LibLua.pushlightuserdata(@state, value.closure_data)
        LibLua.pushlightuserdata(@state, value.pointer)
        LibLua.pushcclosure(@state, ->call(LibLua::State), 2)
      else
        LibLua.pushcclosure(@state, value, 0)
      end
    end

    def push_format(format : String, *args : _) : Nil
      LibLua.pushfstring(@state, format, args)
    end

    def push_global_table : Nil
      LibLua.pushglobaltable(@state)
    end

    def push(value : Int) : Nil
      LibLua.pushinteger(@state, value)
    end

    def push_light_userdata(ptr : Void*) : Nil
      LibLua.pushlightuserdata(@state, ptr)
    end

    def push(value : String, with_len : Bool = true) : Nil
      if with_len
        LibLua.pushlstring(@state, value, value.size)
      else
        LibLua.pushstring(@state, value)
      end
    end

    def push_nil : Nil
      LibLua.pushnil(@state)
    end

    def push(value : Number) : Nil
      LibLua.pushnumber(@state, value)
    end

    def push_thread : Nil
      LibLua.pushthread(@state)
    end

    def push_value(index : Int32) : Nil
      LibLua.pushvalue(@state, index)
    end

    private def call(state : LibLua::State) : Int32
      data = LibLua.topointer(@state, -1_001_000 - 1)
      ptr = LibLua.topointer(@state, -1_001_000 - 2)
      proc = Proc(LibLua::State, Int32).new(ptr, data)

      proc.call(@state)
    end
  end
end
