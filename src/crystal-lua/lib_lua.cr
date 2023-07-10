@[Link("lua")]
lib LibLua
  LUA_IDSIZE = 60

  type State = Void*

  struct Debug
    event : LibC::Int
    name : LibC::Char*
    namewhat : LibC::Char*
    what : LibC::Char*
    source : LibC::Char*
    srclen : LibC::SizeT
    currentline : LibC::Int
    linedefined : LibC::Int
    lastlinedefined : LibC::Int
    nups : UInt8
    nparams : UInt8
    isvararg : LibC::Char
    istailcall : LibC::Char
    ftransfer : LibC::UShort
    ntransfer : LibC::UShort
    short_src : LibC::Char[LUA_IDSIZE]
  end

  fun new_state = luaL_newstate : State
  fun version = lua_version(l : State) : LibC::Double
  fun close = lua_close(l : State) : Void

  fun push_nil = lua_pushnil(l : State) : Void
  fun push_integer = lua_pushinteger(l : State, i : LibC::Long) : Void
  fun push_number = lua_pushnumber(l : State, n : LibC::Double) : Void
  fun push_string = lua_pushstring(l : State, s : LibC::Char*) : Void
  fun push_bool = lua_pushboolean(l : State, b : LibC::Int) : Void

  fun create_table = lua_createtable(l : State, narr : LibC::Int, nrec : LibC::Int) : Void
  fun set_table = lua_settable(l : State, idx : LibC::Int) : Void
end
