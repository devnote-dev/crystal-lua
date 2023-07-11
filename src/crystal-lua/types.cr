module Lua
  enum Type
    NONE = -1
    NIL
    BOOLEAN
    LIGHT_USER_DATA
    NUMBER
    STRING
    TABLE
    FUNCTION
    USER_DATA
    THREAD
  end

  enum Call
    OK
    YIELD
    ERRRUN
    ERRSYNTAX
    ERRMEM
    ERRERR
    ERRFILE
  end
end
