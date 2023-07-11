module Lua
  abstract class Object
    @stack : Stack
    getter ref : Int32

    def initialize(@stack : Stack, @ref : Int32 = 0)
    end

    protected def preload(stack : Stack = @stack, & : Int32 ->)
      raise "Object does not have a reference in the registry" if @ref < 1

      copy_to_stack stack
      yield stack.size
    ensure
      stack.remove
    end

    protected def copy_to_stack(stack : Stack = @stack)
      raise "Object does not have a reference in the registry" if @ref < 1

      stack.get_ref @ref.as(Int32)
    end

    def release(stack : Stack = @stack)
      if !stack.closed? && (ref = @ref)
        stack.unref ref
        ref = nil
      end
    end
  end

  class Reference
    @stack : Stack
    getter ref : Void*

    def initialize(@stack : Stack, @ref : Void*)
    end
  end

  class Function < Object
    def call(*args)
      preload do |pos|
        @stack.call_and_return pos, *args
      end
    end
  end
end
