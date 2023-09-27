{% if flag?(:win32) %}
  @[Link("#{__DIR__}\\..\\..\\ext\\build\\lua-5.4.4\\Release\\lua_static")]
{% else %}
  @[Link("lua")]
{% end %}
lib LibLua
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

  enum StatusCode : Int32
    OK
    YIELD
    ERRRUN
    ERRSYNTAX
    ERRMEM
    ERRERR
    ERRFILE
  end

  # General
  fun atpanic = lua_atpanic(l : State, fn : CFunction) : CFunction
  fun close = lua_close(l : State) : Void
  fun dump = lua_dump(l : State, writer : Writer, data : Void*, strip : LibC::Int) : LibC::Int
  fun error = lua_error(l : State) : LibC::Int
  fun load = lua_load(l : State, reader : Reader, data : Void*, chunkname : LibC::Char*, mode : LibC::Char*) : LibC::Int
  fun newstate = lua_newstate(fn : Alloc, ud : Void*) : State
  fun setwarnf = lua_setwarnf(l : State, fn : WarnFunction, ud : Void*) : Void
  fun version = lua_version(l : State) : Number
  fun warning = lua_warning(l : State, msg : LibC::Char*, tocont : LibC::Int) : Void

  # Threading
  fun closethread = lua_closethread(l : State, thread : State) : LibC::Int
  fun newthread = lua_newthread(l : State) : State
  fun resetthread = lua_resetthread(l : State) : LibC::Int
  fun status = lua_status(l : State) : LibC::Int

  # Stack Control
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

  struct VaListTag
    gp_offset : LibC::UInt
    fp_offset : LibC::UInt
    overflow_arg_area : Void*
    reg_save_area : Void*
  end

  fun pushboolean = lua_pushboolean(l : State, bool : LibC::Int) : Void
  fun pushcclosure = lua_pushcclosure(l : State, fn : CFunction, num : LibC::Int) : Void
  fun pushfstring = lua_pushfstring(l : State, fmt : LibC::Char*, ...) : LibC::Char*
  fun pushinteger = lua_pushinteger(l : State, int : Integer) : Void
  fun pushlightuserdata = lua_pushlightuserdata(l : State, ptr : Void*) : Void
  fun pushlstring = lua_pushlstring(l : State, str : LibC::Char*, len : LibC::SizeT) : LibC::Char*
  fun pushnil = lua_pushnil(l : State) : Void
  fun pushnumber = lua_pushnumber(l : State, num : Number) : Void
  fun pushstring = lua_pushstring(l : State, str : LibC::Char*) : LibC::Char*
  fun pushthread = lua_pushthread(l : State) : LibC::Int
  fun pushvalue = lua_pushvalue(l : State, index : LibC::Int) : Void
  fun pushvfstring = lua_pushvfstring(l : State, fmt : LibC::Char*, argp : VaListTag*) : LibC::Char*

  fun rawequal = lua_rawequal(l : State, x1 : LibC::Int, x2 : LibC::Int, op : Compare) : LibC::Int
  fun rawget = lua_rawget(l : State, index : LibC::Int) : LibC::Int
  fun rawgeti = lua_rawgeti(l : State, index : LibC::Int, int : Integer) : LibC::Int
  fun rawgetp = lua_rawgetp(l : State, index : LibC::Int, ptr : Void*) : LibC::Int
  fun rawlen = lua_rawlen(l : State, index : LibC::Int) : Unsigned
  fun rawset = lua_rawset(l : State, index : LibC::Int) : Void
  fun rawseti = lua_rawseti(l : State, index : LibC::Int, num : Integer) : Void
  fun rawsetp = lua_rawsetp(l : State, index : LibC::Int, ptr : Void*) : Void

  fun setfield = lua_setfield(l : State, index : LibC::Int, key : LibC::Char*) : Void
  fun setglobal = lua_setglobal(l : State, name : LibC::Char*) : Void
  fun seti = lua_seti(l : State, index : LibC::Int, int : Integer) : Void
  fun setiuservalue = lua_setiuservalue(l : State, index : LibC::Int, num : LibC::Int) : LibC::Int
  fun setmetatable = lua_setmetatable(l : State, index : LibC::Int) : LibC::Int
  fun settable = lua_settable(l : State, index : LibC::Int) : Void
  fun settop = lua_settop(l : State, index : LibC::Int) : Void

  fun absindex = lua_absindex(l : State, index : LibC::Int) : LibC::Int
  fun arith = lua_arith(l : State, op : Arith) : Void
  fun callk = lua_callk(l : State, nargs : LibC::Int, nresults : LibC::Int, ctx : KContext, fn : KFunction) : Void
  fun checkstack = lua_checkstack(l : State, num : LibC::Int) : LibC::Int
  fun compare = lua_compare(l : State, x1 : LibC::Int, x2 : LibC::Int, op : Compare) : LibC::Int
  fun concat = lua_concat(l : State, index : LibC::Int) : Void
  fun copy = lua_copy(l : State, from : LibC::Int, to : LibC::Int) : Void
  fun createtable = lua_createtable(l : State, narr : LibC::Int, nrec : LibC::Int) : Void
  fun getfield = lua_getfield(l : State, index : LibC::Int, key : LibC::Char*) : LibC::Int
  fun getglobal = lua_getglobal(l : State, name : LibC::Char*) : LibC::Int
  fun geti = lua_geti(l : State, index : LibC::Int, int : Integer) : LibC::Int
  fun getiuservalue = lua_getiuservalue(l : State, index : LibC::Int, num : LibC::Int) : LibC::Int
  fun getmetatable = lua_getmetatable(l : State, index : LibC::Int) : LibC::Int
  fun gettable = lua_gettable(l : State, index : LibC::Int) : LibC::Int
  fun gettop = lua_gettop(l : State) : LibC::Int
  fun len = lua_len(l : State, index : LibC::Int) : Void
  fun next = lua_next(l : State, index : LibC::Int) : LibC::Int
  fun newuserdatauv = lua_newuserdatauv(l : State, size : LibC::SizeT, nuvalue : LibC::Int) : Void*
  fun pcallk = lua_pcallk(l : State, nargs : LibC::Int, nresults : LibC::Int, errfunc : LibC::Int, ctx : KContext, dn : KFunction) : LibC::Int
  fun rotate = lua_rotate(l : State, index : LibC::Int, num : LibC::Int) : Void
  fun type = lua_type(l : State, index : LibC::Int) : Lua::Type
  fun typename = lua_typename(l : State, type : Lua::Type) : LibC::Char*

  # Type Control
  fun iscfunction = lua_iscfunction(l : State, index : LibC::Int) : LibC::Int
  fun isinteger = lua_isinteger(l : State, index : LibC::Int) : LibC::Int
  fun isnumber = lua_isnumber(l : State, index : LibC::Int) : LibC::Int
  fun isstring = lua_isstring(l : State, index : LibC::Int) : LibC::Int
  fun isuserdata = lua_isuserdata(l : State, index : LibC::Int) : LibC::Int
  fun isyieldable = lua_isyieldable(l : State) : LibC::Int

  fun toboolean = lua_toboolean(l : State, index : LibC::Int) : LibC::Int
  fun tocfunction = lua_tocfunction(l : State, index : LibC::Int) : CFunction
  fun toclose = lua_toclose(l : State, index : LibC::Int) : Void
  fun tointegerx = lua_tointegerx(l : State, index : LibC::Int, isnum : LibC::Int*) : Integer
  fun tolstring = lua_tolstring(l : State, index : LibC::Int, len : LibC::SizeT*) : LibC::Char*
  fun tonumberx = lua_tonumberx(l : State, index : LibC::Int, isnum : LibC::Int*) : Number
  fun topointer = lua_topointer(l : State, index : LibC::Int) : Void*
  fun tothread = lua_tothread(l : State, index : LibC::Int) : State
  fun touserdata = lua_touserdata(l : State, index : LibC::Int) : Void*

  fun numbertointeger = lua_numbertointeger(num : Number, int : Integer*) : LibC::Int
  fun stringtonumber = lua_stringtonumber(l : State, str : LibC::Char*) : LibC::SizeT

  # Coroutine Control
  fun resume = lua_resume(l : State, from : State, nargs : LibC::Int, nresults : LibC::Int*) : LibC::Int
  fun xmove = lua_xmove(l : State, to : State, num : LibC::Int) : Void
  fun yield = lua_yield(from : State, to : State, num : LibC::Int) : LibC::Int
  fun yieldk = lua_yieldk(l : State, nresults : LibC::Int, ctx : KContext, fn : KFunction) : LibC::Int

  # Memory Management
  fun closeslot = lua_closeslot(l : State, index : LibC::Int) : Void
  fun gc = lua_gc(l : State, what : LibC::Int, ...) : LibC::Int
  fun getallocf = lua_getallocf(l : State, ud : Void**) : Alloc
  fun setallocf = lua_setallocf(l : State, fn : Alloc, ud : Void*) : Void

  # Libraries
  fun open_base = luaopen_base(l : State) : LibC::Int
  fun open_coroutine = luaopen_coroutine(l : State) : LibC::Int
  fun open_debug = luaopen_debug(l : State) : LibC::Int
  fun open_io = luaopen_io(l : State) : LibC::Int
  fun open_math = luaopen_math(l : State) : LibC::Int
  fun open_os = luaopen_os(l : State) : LibC::Int
  fun open_package = luaopen_package(l : State) : LibC::Int
  fun open_string = luaopen_string(l : State) : LibC::Int
  fun open_table = luaopen_table(l : State) : LibC::Int
  fun open_utf8 = luaopen_utf8(l : State) : LibC::Int

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
    short_src : LibC::Char[60]
  end

  fun gethook = lua_gethook(l : State) : Hook
  fun gethookcount = lua_gethookcount(l : State) : LibC::Int
  fun gethookmask = lua_gethookmask(l : State) : LibC::Int
  fun getinfo = lua_getinfo(l : State, what : LibC::Char*, ar : Debug*) : LibC::Int
  fun getlocal = lua_getlocal(l : State, ar : Debug*, num : LibC::Int) : LibC::Char*
  fun getstack = lua_getstack(l : State, level : LibC::Int, ar : Debug*) : LibC::Int
  fun getupvalue = lua_getupvalue(l : State, index : LibC::Int, num : LibC::Int) : LibC::Char*
  fun sethook = lua_sethook(l : State, fn : Hook, mask : LibC::Int, count : LibC::Int) : Void
  fun setlocal = lua_setlocal(l : State, ar : Debug*, num : LibC::Int) : LibC::Char*
  fun setupvalue = lua_setupvalue(l : State, index : LibC::Int, num : LibC::Int) : LibC::Char*
  fun upvalueid = lua_upvalueid(l : State, index : LibC::Int, num : LibC::Int) : Void*
  fun upvaluejoin = lua_upvaluejoin(l : State, x1 : LibC::Int, n1 : LibC::Int, x2 : LibC::Int, n2 : LibC::Int) : Void

  # Auxilliary
  type Buffer = Void*

  struct Reg
    name : LibC::Char*
    func : CFunction
  end

  fun l_buffaddr = luaL_bufferaddr(b : Buffer) : LibC::Char*
  fun l_buffinit = luaL_buffinit(l : State, buff : Buffer) : Void
  fun l_bufflen = luaL_bufflen(b : Buffer) : LibC::SizeT
  fun l_buffinitsize = luaL_buffinitsize(l : State, buff : Buffer, size : LibC::SizeT) : LibC::Char*
  fun l_buffsub = luaL_buffsub(b : Buffer, num : LibC::Int) : Void

  fun l_checkany = luaL_checkany(l : State, arg : LibC::Int) : Void
  fun l_checkinteger = luaL_checkinteger(l : State, arg : LibC::Int) : Integer
  fun l_checklstring = luaL_checklstring(l : State, arg : LibC::Int) : LibC::Char*
  fun l_checknumber = luaL_checknumber(l : State, arg : LibC::Int) : Number
  fun l_checkoption = luaL_checkoption(l : State, arg : LibC::Int, _def : LibC::Char*, list : LibC::Char**) : LibC::Int
  fun l_checkstack = luaL_checkstack(l : State, size : LibC::Int, msg : LibC::Char*) : Void
  fun l_checkstring = luaL_checkstring(l : State, arg : LibC::Int) : LibC::Char*
  fun l_checktype = luaL_checktype(l : State, arg : LibC::Int, type : LibC::Int) : Void
  fun l_checkudata = luaL_checkudata(l : State, arg : LibC::Int, name : LibC::Char*) : Void
  fun l_checkversion = luaL_checkversion(l : State) : Void

  fun l_loadbufferx = luaL_loadbufferx(l : State, buff : LibC::Char*, size : LibC::SizeT, name : LibC::Char*, mode : LibC::Char*) : LibC::Int
  fun l_loadfilex = luaL_loadfilex(l : State, name : LibC::Char*, mode : LibC::Char*) : LibC::Int
  fun l_loadstring = luaL_loadstring(l : State, str : LibC::Char*) : LibC::Int

  fun l_optinteger = luaL_optinteger(l : State, arg : LibC::Int, d : Integer) : Integer
  fun l_optlstring = luaL_optlstring(l : State, arg : LibC::Int, d : LibC::Char*, len : LibC::SizeT*) : LibC::Char*
  fun l_optnumber = luaL_optnumber(l : State, arg : LibC::Int, d : Number) : Number
  fun l_optstring = luaL_optstring(l : State, arg : LibC::Int, d : LibC::Char*) : LibC::Char*

  fun l_callmeta = luaL_callmeta(l : State, obj : LibC::Int, name : LibC::Char*) : LibC::Int
  fun l_dofile = luaL_dofile(l : State, name : LibC::Char*) : LibC::Int
  fun l_dostring = luaL_dostring(l : State, str : LibC::Char*) : LibC::Int
  fun l_error = luaL_error(l : State, fmt : LibC::Char*, ...) : LibC::Int
  fun l_execresult = luaL_execresult(l : State, stat : LibC::Int) : LibC::Int
  fun l_fileresult = luaL_fileresult(l : State, stat : LibC::Int, name : LibC::Char*) : LibC::Int
  fun l_getmetafield = luaL_getmetafield(l : State, obj : LibC::Int, name : LibC::Char*) : LibC::Int
  fun l_getmetatable = luaL_getmetatable(l : State, name : LibC::Char*) : LibC::Int
  fun l_getsubtable = luaL_getsubtable(l : State, index : LibC::Int, name : LibC::Char*) : LibC::Int
  fun l_gsub = luaL_gsub(l : State, str : LibC::Char*, pat : LibC::Char*, re : LibC::Char*) : LibC::Char*
  fun l_len = luaL_len(l : State, index : LibC::Int) : Integer
  # fun l_newlib = luaL_newlib(l : State, reg : Array(Reg)) : Void
  # fun l_newlibtable = luaL_newlibtable(l : State, reg : Array(Reg)) : Void
  fun l_newmetatable = luaL_newmetatable(l : State, name : LibC::Char*) : LibC::Int
  fun l_newstate = luaL_newstate : State
  fun l_openlibs = luaL_openlibs(l : State) : Void
  fun l_prepbuffer = luaL_prepbuffer(b : Buffer, size : LibC::SizeT) : LibC::Char*
  fun l_pushfail = luaL_pushfail(l : State) : Void
  fun l_pushresult = luaL_pushresult(b : Buffer) : Void
  fun l_pushresultsize = luaL_pushresultsize(b : Buffer, size : LibC::SizeT) : Void
  fun l_ref = luaL_ref(l : State, index : LibC::Int) : LibC::Int
  fun l_requiref = luaL_requiref(l : State, name : LibC::Char*, fn : CFunction, global : LibC::Int) : Void
  fun l_setfuncs = luaL_setfuncs(l : State, reg : Reg*, nup : LibC::Int) : Void
  fun l_setmetatable = luaL_setmetatable(l : State, name : LibC::Char*) : Void
  fun l_testudata = luaL_testudata(l : State, arg : LibC::Int, name : LibC::Char*) : Void
  fun l_tolstring = luaL_tolstring(l : State, index : LibC::Int, len : LibC::SizeT) : LibC::Char*
  fun l_traceback = luaL_traceback(l : State, l1 : State, msg : LibC::Char*, level : LibC::Int) : Void
  fun l_typeerror = luaL_typeerror(l : State, arg : LibC::Int, name : LibC::Char*) : LibC::Int
  fun l_typename = luaL_typename(l : State, index : LibC::Int) : LibC::Char*
  fun l_unref = luaL_unref(l : State, index : LibC::Int, ref : LibC::Int) : Void
  fun l_where = luaL_where(l : State, level : LibC::Int) : Void
end
