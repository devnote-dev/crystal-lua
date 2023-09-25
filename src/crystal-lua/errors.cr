module Lua
  class Error < Exception
    def self.from_status(code : Int32, message : String)
      case LibLua::StatusCode.new(code)
      when .errrun?
        RuntimeError.new message
      when .errsyntax?
        SyntaxError.new message
      when .errmem?
        MemoryError.new message
      when .errfile?
        FileError.new message
      else
        FailError.new message, code
      end
    end
  end

  class FailError < Error
    getter code : Int32?

    def initialize(@message : String, @code : Int32?)
    end
  end

  class RuntimeError < Error
  end

  class SyntaxError < Error
  end

  class MemoryError < Error
  end

  class MessageHandlerError < Error
  end

  class FileError < Error
  end
end
