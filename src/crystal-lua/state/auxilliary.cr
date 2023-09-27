module Lua
  class State
    def load_buffer(buf : IO, mode : Mode? = nil) : Array(Any)
      code = LibLua.l_loadbufferx(@state, buf.gets_to_end, buf.size, nil, mode.try &.to_s)
      raise Error.from_status(code) unless code == 0

      call_and_return size
    end

    def load_file(path : Path | String, mode : Mode? = nil) : Array(Any)
      code = LibLua.l_loadfilex(@state, path.to_s, mode.try &.to_s)
      raise Error.from_status(code) unless code == 0

      call_and_return size
    end

    def load_string(source : String) : Array(Any)
      code = LibLua.l_loadstring(@state, source)
      raise Error.from_status(code) unless code == 0

      call_and_return size
    end

    def call_and_return(pos : Int32, args : Enumerable(Any::Type) = %w[]) : Array(Any)
      args.each { |arg| push arg }
      code = LibLua.pcallk(@state, args.size, 1, 0, 0, nil)
      raise Error.from_status(code) unless code == 0

      (pos..size).compact_map { pop }
    end

    def run_file(path : Path | String) : Nil
      code = LibLua.l_dofile(@state, path.to_s)
      raise Error.from_status(code) unless code == 0
    end

    def run_string(source : String) : Nil
      code = LibLua.l_dostring(@state, source)
      raise Error.from_status(code) unless code == 0
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
