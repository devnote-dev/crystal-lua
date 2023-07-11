module Lua
  class Error < Exception
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
