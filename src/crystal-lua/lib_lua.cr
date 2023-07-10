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
  fun version = lua_version(l : State) : LibC::Int
  fun close = lua_close(l : State) : Void
end
