module Lua
  class Error < Exception
    getter code : Int32?

    def self.from_status(code : Int32, message : String? = nil)
      case LibLua::StatusCode.new(code)
      when .errrun?
        RuntimeError.new code, message
      when .errsyntax?
        SyntaxError.new code, message
      when .errmem?
        MemoryError.new code, message
      when .errfile?
        FileError.new code, message
      else
        FailError.new code, message
      end
    end

    def initialize(@message : String?)
    end

    def initialize(@code : Int32, @message : String?)
    end
  end

  class FailError < Error
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
