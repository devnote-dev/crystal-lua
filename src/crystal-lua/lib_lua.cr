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

  fun is_number = lua_isnumber(l : State, idx : LibC::Int) : LibC::Int
  fun is_string = lua_isstring(l : State, idx : LibC::Int) : LibC::Int
  fun is_c_function = lua_iscfunction(l : State, idx : LibC::Int) : LibC::Int
  fun is_userdata = lua_isuserdata(l : State, idx : LibC::Int) : LibC::Int
  fun is_yieldable = lua_isyieldable(l : State) : LibC::Int

  fun type = lua_type(l : State, idx : LibC::Int) : LibC::Int
  fun typename = lua_typename(l : State, tp : LibC::Int) : LibC::Char*

  fun to_numberx = lua_tonumberx(l : State, idx : LibC::Int, isnum : LibC::Int*) : LibC::Double
  fun to_integerx = lua_tointegerx(l : State, idx : LibC::Int, isnum : LibC::Int*) : LibC::Long
  fun to_boolean = lua_toboolean(l : State, idx : LibC::Int) : LibC::Int
  fun to_lstring = lua_tolstring(l : State, idx : LibC::Int, len : LibC::SizeT*) : LibC::Char*

  fun create_table = lua_createtable(l : State, narr : LibC::Int, nrec : LibC::Int) : Void
  fun get_table = lua_gettable(l : State, idx : LibC::Int) : Void
  fun get_field = lua_getfield(l : State, idx : LibC::Int, k : LibC::Char*) : Void
  fun set_table = lua_settable(l : State, idx : LibC::Int) : Void

  fun get_metatable = lua_getmetatable(l : State, idx : LibC::Int) : LibC::Int
  fun set_metatable = lua_setmetatable(l : State, idx : LibC::Int) : LibC::Int
end
