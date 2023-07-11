module Lua
  class Error < Exception
    getter traceback : String?

    def initialize(@message : String?, @traceback : String? = nil)
    end
  end

  class RuntimeError < Error
  end

  class SyntaxError < Error
  end

  class MemoryError < Error
  end

  class ErrorHandlerError < Error
  end

  class FileError < Error
  end
end
