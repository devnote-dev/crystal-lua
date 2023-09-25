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

      @state = LibLua.newstate
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
