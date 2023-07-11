module Lua
  class Stack
    REGISTRY_INDEX = -1_001_000

    @state : LibLua::State
    @error_handler : Function?
    getter? closed : Bool

    def self.new(& : self ->) : self
      this = new
      yield this
      this
    end

    def initialize
      @state = LibLua.new_state

      unless (ver = LibLua.version(@state)) >= 504
        LibLua.close @state
        raise "Lua version #{ver} not supported"
      end

      @closed = false
    end

    def close : Nil
      return if closed?

      LibLua.close @state
      @closed = true
    end

    def finalize
      close
    end

    def run(buf : String, name : String? = nil)
      call = Call.new LibLua.l_load_bufferx(@state, buf, buf.size, name || buf.strip, nil)
      error call unless call.ok?
      call_and_return size
    end

    def call_and_return(pos : Int, *args)
      error_pos = load_error_handler pos
      pos += 1 if error_pos != 0
      args.each { |a| push a }

      call = Call.new LibLua.pcallk(@state, args.size, -1, error_pos, 0, nil)
      error call unless call.ok?

      items = (pos..size).map { pop }
      items.size > 1 ? items : items[0]
    ensure
      remove if error_pos != 0
    end

    def set_error_handler(chunk : String) : Nil
      res = run chunk, "error handler"
      raise "Error handler must return a function" unless res.is_a? Function
      @error_handler = res
    end

    def load_error_handler(pos : Int)
      if handler = @error_handler
        handler.copy_to_stack
        LibLua.rotate @state, pos, -1

        pos
      else
        0
      end
    end

    protected def error(call : Call, message : String? = nil, traceback : String? = nil) : NoReturn
      case call
      when .errrun?    then raise RuntimeError.new message, traceback
      when .errsyntax? then raise SyntaxError.new message, traceback
      when .errmem?    then raise MemoryError.new message, traceback
      when .errerr?    then raise ErrorHandlerError.new message, traceback
      when .errfile?   then raise FileError.new message, traceback
      else                  raise Error.new message, traceback
      end
    end

    def <<(object : _) : Nil
      push object
    end

    def push(object : Nil) : Nil
      LibLua.push_nil @state
    end

    def push(object : Int) : Nil
      LibLua.push_integer @state, object
    end

    def push(object : Float) : Nil
      LibLua.push_number @state, object
    end

    def push(object : String) : Nil
      LibLua.push_string @state, object
    end

    def push(object : Bool) : Nil
      LibLua.push_bool(@state, object ? 1 : 0)
    end

    def push(object : Symbol) : Nil
      LibLua.push_string @state, object.to_s
    end

    def push(object : Array | Deque | Tuple | Set) : Nil
      hash = object.to_a.map_with_index { |e, i| {i + 1, e} }.to_h
      push_table hash, object.size, 0
    end

    def push(object : Hash | NamedTuple) : Nil
      push_table object.to_h, 0, object.size
    end

    def push_table(hash : Hash, narr : Int32, nrec : Int32) : Nil
      LibLua.create_table @state, narr, nrec

      hash.each do |key, value|
        push key
        push value
        LibLua.set_table @state, -3
      end
    end

    def [](pos : Int)
      index pos
    end

    def index(pos : Int32)
      return nil if pos == 0

      case type_at(pos)
      in .none?, Type::NIL
        nil
      in .boolean?
        LibLua.to_boolean(@state, pos) == 1
      in .light_user_data?
        raise NotImplementedError.new "Reference"
      in .number?
        LibLua.to_numberx(@state, pos, nil)
      in .string?
        LibLua.to_lstring(@state, pos, nil)
      in .table?
        raise NotImplementedError.new "Table"
      in .function?
        raise NotImplementedError.new "Function"
      in .user_data?
        raise NotImplementedError.new "Callable"
      in .thread?
        raise NotImplementedError.new "Coroutine"
      end
    end

    def type_at(pos : Int) : Type
      Type.new LibLua.type(@state, pos)
    end

    def crystal_type_at(pos : Int) : String
      if LibLua.get_metatable(@state, pos) == 0
        raise "Index #{pos} is invalid or does not have a metatable"
      end

      LibLua.push_string @state, "__name"
      LibLua.get_table @state, -2
      type = index(-1).as(String)
      LibLua.set_top @state, -3

      type
    end

    def crystal_base_type_at(pos : Int) : String
      if LibLua.get_metatable(@state, pos) == 0
        raise "Index #{pos} is invalid or does not have a metatable"
      end

      LibLua.push_string @state, "__crystal_base_type"
      LibLua.get_table @state, -2
      type = index(-1).as(String)
      LibLua.set_top @state, -3

      type
    end

    def crystal_type_info_at(pos : Int) : {String?, String}
      if LibLua.get_metatable(@state, pos) == 0
        raise "Index #{pos} is invalid or does not have a metatable"
      end

      LibLua.push_string @state, "__name"
      LibLua.get_table @state, -2
      type = index(-1).as(String)
      LibLua.push_string @state, "__crystal_base_type"
      LibLua.get_table @state, -3
      base = index(-1).as?(String)
      LibLua.set_top @state, -4

      {base, type}
    end

    def new_ref(pos : Int)
      LibLua.push_value @state, pos
      LibLua.l_ref @state, REGISTRY_INDEX
    end

    def get_ref(ref : Int32)
      Type.new LibLua.rawgeti(@state, REGISTRY_INDEX, ref)
    end

    def unref(ref : Int32)
      LibLua.l_unref @state, REGISTRY_INDEX, ref
    end

    def size : Int
      LibLua.get_top @state
    end

    def top
      index size
    end

    def pop
      top.try &.tap { remove }
    end

    def remove(n : Int = 1) : Nil
      n = 0 if n < 0
      n = size if n > size
      LibLua.set_top(@state, -n - 1)
    end
  end
end
