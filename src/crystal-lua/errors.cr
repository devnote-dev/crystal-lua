module Lua
  class Error < Exception
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
