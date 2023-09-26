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

  class State
    @state : LibLua::State
    getter library : Library
    getter? closed : Bool

    def initialize
      # TODO: should Lua be hooked up to Crystal's GC?
      #
      # alloc = ->(data : Void*, ptr : Void*, osize : LibC::SizeT, nsize : LibC::SizeT) do
      #   Pointer(Void).null
      # end
      # @state = LibLua.newstate(alloc, alloc.pointer)

      @state = LibLua.l_newstate
      @library = :none
      @closed = false
    end

    def open_library(libs : Library) : Nil
      {% for name in %i(base coroutine table io os string utf8 math debug package) %}
        if libs.{{ name.id }}? && !@library.{{ name.id }}?
          _ = LibLua.open_{{ name.id }}(@state)
          @library |= {{ name }}
        end
      {% end %}
    end

    def size : Int32
      LibLua.gettop(@state)
    end

    def top : Any?
      index size
    end

    def pop : Any?
      top.try &.tap { remove }
    end

    def remove : Nil
      LibLua.settop(@state, -2)
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
      type = index(-1).as_s

      LibLua.pushstring(@state, "__crystal_type")
      LibLua.gettable(@state, -3)
      base = index(-1).as_s?

      LibLua.settop(@state, -4)

      {base, type}
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
