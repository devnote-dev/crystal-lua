require "./state/*"

module Lua
  @[Flags]
  enum Library
    Base
    Coroutine
    Table
    IO
    OS
    String
    UTF8
    Math
    Debug
    Package
  end

  enum Mode : UInt8
    Binary
    Text
    BinaryText

    def to_s : String
      case self
      in .binary?      then "b"
      in .text?        then "t"
      in .binary_text? then "bt"
      end
    end
  end

  enum Type : Int8
    None          = -1
    Nil
    Boolean
    LightUserdata
    Number
    String
    Table
    Function
    Userdata
    Thread
  end

  class State
    @state : LibLua::State
    getter library : Library
    getter? closed : Bool

    def self.new
      state = LibLua.l_newstate
      raise MemoryError.new "Failed to init new state" if state.null?

      new state
    end

    def initialize(@state : LibLua::State, @library : Library = :none)
      @closed = false
    end

    def at_panic(&block : LibLua::CFunction) : LibLua::CFunction
      LibLua.atpanic(@state, block)
    end

    def set_warn_function(&block : LibLua::WarnFunction) : Nil
      LibLua.setwarnf(@state, block, nil)
    end

    def version : Float64
      LibLua.version(@state)
    end

    def warning(message : String, continue : Bool = false) : Nil
      LibLua.warning(@state, message, continue)
    end

    def size : Int32
      LibLua.gettop(@state)
    end

    def set_global(name : String) : Nil
      LibLua.setglobal(@state, name)
    end

    def set_metatable(index : Int32) : Nil
      LibLua.setmetatable(@state, index)
    end

    def set_table(index : Int32) : Nil
      LibLua.settable(@state, index)
    end

    def call(num_args : Int32, num_results : Int32) : Nil
      code = LibLua.callk(@state, num_args, num_results, 0, nil)
      raise Error.from_status(code, pop!.as_s) unless code == 0
    end

    def call(num_args : Int32, num_results : Int32, context : LibLua::KContext, fn : LibLua::KFunction) : Nil
      code = LibLua.callk(@state, num_args, num_results, context, fn)
      raise Error.from_status(code, pop!.as_s) unless code == 0
    end

    def next(index : Int32) : Bool
      LibLua.next(@state, index) != 0
    end

    def new_userdata(size : Int32, values : Int32) : Void*
      LibLua.newuserdatauv(@state, size, values)
    end

    def protected_call(num_args : Int32, num_results : Int32, msg_handler : Int32) : Nil
      code = LibLua.pcallk(@state, num_args, num_results, msg_handler, 0, nil)
      raise Error.from_status(code, pop!.as_s) unless code == 0
    end

    def protected_call(num_args : Int32, num_results : Int32, msg_handler : Int32,
                       context : LibLua::KContext, fn : LibLua::KFunction) : Nil
      code = LibLua.pcallk(@state, num_args, num_results, msg_handler, context, fn)
      raise Error.from_status(code, pop!.as_s) unless code == 0
    end

    def rotate(index : Int32, times : Int32) : Nil
      LibLua.rotate(@state, index, times)
    end

    def type_at(pos : Int32) : Type
      LibLua.type(@state, pos)
    end

    def typename(pos : Int32) : String
      typename type_at(pos)
    end

    def typename(type : Type) : String
      String.new LibLua.typename(@state, type)
    end

    private def crystal_type_info(pos : Int32) : {String?, String}
      if LibLua.getmetatable(@state, pos) == 0
        raise Error.new "Value at #{pos} does not have a metatable"
      end

      LibLua.pushstring(@state, "__name")
      LibLua.gettable(@state, -2)
      type = index!(-1).as_s

      LibLua.pushstring(@state, "__crystal_type")
      LibLua.gettable(@state, -3)
      base = index!(-1).as_s?

      LibLua.settop(@state, -4)

      {base, type}
    end

    def index(pos : Int32) : Any?
      return nil if pos == 0

      case type_at pos
      when Type::Nil, Type::None
        Any.new nil
      when .boolean?
        Any.new LibLua.toboolean(@state, pos) != 0
      when .light_userdata?
        Any.new Reference.new(self, LibLua.topointer(@state, pos))
      when .number?
        Any.new LibLua.tonumberx(@state, pos, nil)
      when .string?
        Any.new String.new(LibLua.tolstring(@state, pos, nil))
      when .table?
        Any.new Table.new(self, reference(pos))
      when .function?
        Any.new Function.new(self, reference(pos))
        # when .userdata?
        #   base, type = crystal_type_info pos
        #   if !base.nil? && type == "callable"
        #     Any.new Callable.new(self, LibLua.touserdata(@state, pos), type)
        #   else
        #     Any.new Reference.new(self, LibLua.topointer(@state, pos))
        #   end
        # when .thread?
        #   Any.new Coroutine.new(State.new(LibLua.tothread(@state, pos), @library))
      else
        raise Error.new "Unknown Lua type: #{typename(pos)}"
      end
    end

    def index!(pos : Int32) : Any
      index(pos) || raise IndexError.new "No value at index #{pos}"
    end

    def top : Any?
      index size
    end

    def pop : Any?
      top.try &.tap { remove }
    end

    def pop! : Any
      pop || raise IndexError.new "Stack is empty"
    end

    def remove : Nil
      LibLua.settop(@state, -2)
    end

    def open(libs : Library) : Nil
      {% for name in %i(base coroutine table io os string utf8 math debug package) %}
        if libs.{{ name.id }}? && !@library.{{ name.id }}?
          _ = LibLua.open_{{ name.id }}(@state)
          @library |= {{ name }}
        end
      {% end %}
    end

    def close : Nil
      return if @closed

      LibLua.close @state
      @closed = true
    end

    def finalize
      close
    end

    def to_unsafe
      @state
    end
  end
end
