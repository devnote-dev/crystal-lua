@[Link("lua")]
lib LibLua
  LUA_IDSIZE = 60

  type State = Void*

  alias Number = LibC::Double
  alias Integer = LibC::LongLong
  alias Unsigned = LibC::ULongLong
  alias KContext = LibC::SizeT

  alias CFunction = State -> LibC::Int
  alias KFunction = State, LibC::Int, KContext -> LibC::Int
  alias Reader = State, Void*, LibC::SizeT -> LibC::Char*
  alias Writer = State, Void*, LibC::SizeT, Void* -> LibC::Int
  alias Alloc = Void*, Void*, LibC::SizeT, LibC::SizeT -> Void*
  alias WarnFunction = Void*, LibC::Char*, LibC::Int -> Void
  alias Hook = State, Debug -> Void

  enum Arith : UInt32
    OPADD
    OPSUB
    OPMUL
    OPDIV
    OPIDIV
    OPMOD
    OPPOW
    OPUNM
    OPBNOT
    OPBAND
    OPBOR
    OPBXOR
    OPSHL
    OPSHR
  end

  enum Compare : UInt32
    OPEQ
    OPLT
    OPLE
  end

  enum StatusCode : Int32
    OK
    YIELD
    ERRRUN
    ERRSYNTAX
    ERRMEM
    ERRERR
    ERRFILE
  end

  struct VaListTag
    gp_offset : LibC::UInt
    fp_offset : LibC::UInt
    overflow_arg_area : Void*
    reg_save_area : Void*
  end

  # General
  fun newstate = luaL_newstate : State
  # fun newstate = luaL_newstate(fn : Alloc, ud : Void*) : State

  fun close = lua_close(l : State) : Void
  fun load = lua_load(l : State, reader : Reader, data : Void*, chunkname : LibC::Char*, mode : LibC::Char*) : LibC::Int
  fun dump = lua_dump(l : State, writer : Writer, data : Void*, strip : LibC::Int) : LibC::Int
  fun version = lua_version(l : State) : Number
  fun atpanic = lua_atpanic(l : State, fn : CFunction) : CFunction
  fun setwarnf = lua_setwarnf(l : State, fn : WarnFunction, ud : Void*) : Void
  fun warning = lua_warning(l : State, msg : LibC::Char*, tocont : LibC::Int) : Void
  fun error = lua_error(l : State) : LibC::Int

  # Threading
  fun newthread = lua_newthread(l : State) : State
  fun closethread = lua_closethread(l : State, thread : State) : LibC::Int
  fun resetthread = lua_resetthread(l : State) : LibC::Int
  fun status = lua_status(l : State) : LibC::Int

  # Stack Control
  fun gettop = lua_gettop(l : State) : LibC::Int
  fun settop = lua_settop(l : State, index : LibC::Int) : Void
  fun rotate = lua_rotate(l : State, index : LibC::Int, num : LibC::Int) : Void
  fun copy = lua_copy(l : State, from : LibC::Int, to : LibC::Int) : Void
  fun checkstack = lua_checkstack(l : State, num : LibC::Int) : LibC::Int
  fun next = lua_next(l : State, index : LibC::Int) : LibC::Int
  fun concat = lua_concat(l : State, index : LibC::Int) : Void
  fun len = lua_len(l : State, index : LibC::Int) : Void
  fun xmove = lua_xmove(l : State, to : State, num : LibC::Int) : Void
  fun type = lua_type(l : State, index : LibC::Int) : LibC::Int
  fun typename = lua_typename(l : State, index : LibC::Int) : LibC::Char*
  fun toclose = lua_toclose(l : State, index : LibC::Int) : Void

  fun pushvalue = lua_pushvalue(l : State, index : LibC::Int) : Void
  fun pushnil = lua_pushnil(l : State) : Void
  fun pushnumber = lua_pushnumber(l : State, num : Number) : Void
  fun pushinteger = lua_pushinteger(l : State, int : Integer) : Void
  fun pushlstring = lua_pushlstring(l : State, str : LibC::Char*, len : LibC::SizeT) : LibC::Char*
  fun pushstring = lua_pushstring(l : State, str : LibC::Char*) : LibC::Char*
  fun pushvfstring = lua_pushvfstring(l : State, fmt : LibC::Char*, argp : VaListTag*) : LibC::Char*
  fun pushfstring = lua_pushfstring(l : State, fmt : LibC::Char*, ...) : LibC::Char*
  fun pushcclosure = lua_pushcclosure(l : State, fn : CFunction, num : LibC::Int) : Void
  fun pushboolean = lua_pushboolean(l : State, bool : LibC::Int) : Void
  fun pushlightuserdata = lua_pushlightuserdata(l : State, ptr : Void*) : Void
  fun pushthread = lua_pushthread(l : State) : LibC::Int

  # Type Control
  fun isnumber = lua_isnumber(l : State, index : LibC::Int) : LibC::Int
  fun isstring = lua_isstring(l : State, index : LibC::Int) : LibC::Int
  fun iscfunction = lua_iscfunction(l : State, index : LibC::Int) : LibC::Int
  fun isinteger = lua_isinteger(l : State, index : LibC::Int) : LibC::Int
  fun isuserdata = lua_isuserdata(l : State, index : LibC::Int) : LibC::Int
  fun isyieldable = lua_isyieldable(l : State) : LibC::Int

  fun tonumberx = lua_tonumberx(l : State, index : LibC::Int, isnum : LibC::Int*) : Number
  fun tointegerx = lua_tointegerx(l : State, index : LibC::Int, isnum : LibC::Int*) : Integer
  fun toboolean = lua_toboolean(l : State, index : LibC::Int) : LibC::Int
  fun tolstring = lua_tolstring(l : State, index : LibC::Int, len : LibC::SizeT*) : LibC::Char*
  fun tocfunction = lua_tocfunction(l : State, index : LibC::Int) : CFunction
  fun touserdata = lua_touserdata(l : State, index : LibC::Int) : Void*
  fun tothread = lua_tothread(l : State, index : LibC::Int) : State
  fun topointer = lua_topointer(l : State, index : LibC::Int) : Void*

  fun stringtonumber = lua_stringtonumber(l : State, str : LibC::Char*) : LibC::SizeT

  # Closure Control
  fun getupvalue = lua_getupvalue(l : State, index : LibC::Int, num : LibC::Int) : LibC::Char*
  fun setupvalue = lua_setupvalue(l : State, index : LibC::Int, num : LibC::Int) : LibC::Char*
  fun upvalueid = lua_upvalueid(l : State, index : LibC::Int, num : LibC::Int) : Void*
  fun upvaluejoin = lua_upvaluejoin(l : State, x1 : LibC::Int, n1 : LibC::Int, x2 : LibC::Int, n2 : LibC::Int) : Void

  # Coroutine Control
  fun yieldk = lua_yieldk(l : State, nresults : LibC::Int, ctx : KContext, fn : KFunction) : LibC::Int
  fun resume = lua_resume(l : State, from : State, nargs : LibC::Int, nresults : LibC::Int*) : LibC::Int

  # Memory Management
  fun gc = lua_gc(l : State, what : LibC::Int, ...) : LibC::Int
  fun getallocf = lua_getallocf(l : State, ud : Void**) : Alloc
  fun setallocf = lua_setallocf(l : State, fn : Alloc, ud : Void*) : Void
  fun closeslot = lua_closeslot(l : State, index : LibC::Int) : Void

  # Libraries
  fun open_base = luaopen_base(l : State) : LibC::Int
  fun open_coroutine = luaopen_coroutine(l : State) : LibC::Int
  fun open_table = luaopen_table(l : State) : LibC::Int
  fun open_io = luaopen_io(l : State) : LibC::Int
  fun open_os = luaopen_os(l : State) : LibC::Int
  fun open_string = luaopen_string(l : State) : LibC::Int
  fun open_utf8 = luaopen_utf8(l : State) : LibC::Int
  fun open_math = luaopen_math(l : State) : LibC::Int
  fun open_debug = luaopen_debug(l : State) : LibC::Int
  fun open_package = luaopen_package(l : State) : LibC::Int

  # Debugging
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
    nups : LibC::UChar
    nparams : LibC::UChar
    isvararg : LibC::Char
    istailcall : LibC::Char
    ftransfer : LibC::UShort
    ntransfer : LibC::UShort
    short_src : LibC::Char[LUA_IDSIZE]
  end

  fun getstack = lua_getstack(l : State, level : LibC::Int, ar : Debug*) : LibC::Int
  fun getinfo = lua_getinfo(l : State, what : LibC::Char*, ar : Debug*) : LibC::Int
  fun getlocal = lua_getlocal(l : State, ar : Debug*, num : LibC::Int) : LibC::Char*
  fun setlocal = lua_setlocal(l : State, ar : Debug*, num : LibC::Int) : LibC::Char*
  fun gethook = lua_gethook(l : State) : Hook
  fun sethook = lua_sethook(l : State, fn : Hook, mask : LibC::Int, count : LibC::Int) : Void
  fun gethookmask = lua_gethookmask(l : State) : LibC::Int
  fun gethookcount = lua_gethookcount(l : State) : LibC::Int
  fun setcstacklimit = lua_setcstacklimit(l : State, limit : LibC::Int) : LibC::Int

  # Other/ungrouped
  fun absindex = lua_absindex(l : State, index : LibC::Int) : LibC::Int
  fun arith = lua_arith(l : State, op : Arith) : Void
  fun rawequal = lua_rawequal(l : State, x1 : LibC::Int, x2 : LibC::Int, op : Compare) : LibC::Int
  fun compare = lua_compare(l : State, x1 : LibC::Int, x2 : LibC::Int, op : Compare) : LibC::Int
  fun getglobal = lua_getglobal(l : State, name : LibC::Char*) : LibC::Int
  fun gettable = lua_gettable(l : State, index : LibC::Int) : LibC::Int
  fun getfield = lua_getfield(l : State, index : LibC::Int, key : LibC::Char*) : LibC::Int
  fun geti = lua_geti(l : State, index : LibC::Int, int : Integer) : LibC::Int
  fun rawget = lua_rawget(l : State, index : LibC::Int) : LibC::Int
  fun rawgeti = lua_rawgeti(l : State, index : LibC::Int, int : Integer) : LibC::Int
  fun rawgetp = lua_rawgetp(l : State, index : LibC::Int, ptr : Void*) : LibC::Int
  fun createtable = lua_createtable(l : State, narr : LibC::Int, nrec : LibC::Int) : Void
  fun newuserdatauv = lua_newuserdatauv(l : State, size : LibC::SizeT, nuvalue : LibC::Int) : Void*
  fun getmetatable = lua_getmetatable(l : State, index : LibC::Int) : LibC::Int
  fun getiuservalue = lua_getiuservalue(l : State, index : LibC::Int, num : LibC::Int) : LibC::Int
  fun setglobal = lua_setglobal(l : State, name : LibC::Char*) : Void
  fun settable = lua_settable(l : State, index : LibC::Int) : Void
  fun setfield = lua_setfield(l : State, index : LibC::Int, key : LibC::Char*) : Void
  fun seti = lua_seti(l : State, index : LibC::Int, int : Integer) : Void
  fun rawlen = lua_rawlen(l : State, index : LibC::Int) : Unsigned
  fun rawseti = lua_rawseti(l : State, index : LibC::Int, num : Integer) : Void
  fun rawsetp = lua_rawsetp(l : State, index : LibC::Int, ptr : Void*) : Void
  fun setmetatable = lua_setmetatable(l : State, index : LibC::Int) : LibC::Int
  fun setiuservalue = lua_setiuservalue(l : State, index : LibC::Int, num : LibC::Int) : LibC::Int
  fun callk = lua_callk(l : State, nargs : LibC::Int, nresults : LibC::Int, ctx : KContext, fn : KFunction) : Void
  fun pcallk = lua_pcallk(l : State, nresults : LibC::Int, errfunc : LibC::Int, ctx : KContext, dn : KFunction) : LibC::Int

  # TODO: Auxilliary (luaL_*)
end
