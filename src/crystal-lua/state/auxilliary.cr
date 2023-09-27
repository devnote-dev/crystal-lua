module Lua
  class State
    def load_buffer(buf : IO, mode : Mode? = nil) : Nil
      code = LibLua.l_loadbufferx(@state, buf.gets_to_end, buf.size, nil, mode.try &.to_s)
      raise Error.from_status(code) unless code == 0
    end

    def load_file(path : Path | String, mode : Mode? = nil) : Nil
      code = LibLua.l_loadfilex(@state, path.to_s, mode.try &.to_s)
      raise Error.from_status(code) unless code == 0
    end

    def load_string(source : String) : Nil
      code = LibLua.l_loadstring(@state, source)
      raise Error.from_status(code) unless code == 0
    end

    def protected_call(num_args : Int32, num_results : Int32, msg_handler : Int32) : Nil
      code = LibLua.pcallk(@state, num_args, num_results, msg_handler, 0, nil)
      raise Error.from_status(code) unless code == 0
    end

    def protected_call(num_args : Int32, num_results : Int32, msg_handler : Int32,
                       context : LibLua::KContext, fn : LibLua::KFunction) : Nil
      code = LibLua.pcallk(@state, num_args, num_results, msg_handler, context, fn)
      raise Error.from_status(code) unless code == 0
    end

    def run_file(path : Path | String) : Nil
      load_file path, :binary_text
      protected_call 0, -1, 0
    end

    def run_string(source : String) : Nil
      load_string source
      protected_call 0, -1, 0
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
