module Lua
  class State
    def load_buffer(buf : IO, mode : Mode? = nil) : Nil
      code = LibLua.l_loadbufferx(@state, buf.gets_to_end, buf.size, nil, mode.try &.to_s)
      raise Error.from_status(code, pop!.as_s) unless code == 0
    end

    def load_file(path : Path | String, mode : Mode? = nil) : Nil
      code = LibLua.l_loadfilex(@state, path.to_s, mode.try &.to_s)
      raise Error.from_status(code, pop!.as_s) unless code == 0
    end

    def load_string(source : String) : Nil
      code = LibLua.l_loadstring(@state, source)
      raise Error.from_status(code, pop!.as_s) unless code == 0
    end

    def run_file(path : Path | String) : Nil
      load_file path, :binary_text
      protected_call 0, -1, 0
    end

    def run_string(source : String) : Nil
      load_string source
      protected_call 0, -1, 0
    end

    def error(message : String, *args : _) : Nil
      LibLua.l_error(@state, message, *args)
    end

    def new_metatable(name : String) : Nil
      code = LibLua.l_newmetatable(@state, name)
      raise Error.from_status(code, pop!.as_s) unless code == 0
    end

    def reference(pos : Int32) : Int32
      LibLua.pushvalue(@state, pos)
      LibLua.l_ref(@state, -1_001_000)
    end

    def dereference(ref : Int32) : Nil
      LibLua.l_unref(@state, -1_001_000, ref)
    end
  end
end
