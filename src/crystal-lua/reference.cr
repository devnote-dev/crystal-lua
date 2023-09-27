module Lua
  class Reference
    @state : State
    @data : Void*

    def initialize(@state : State, @data : Void*)
    end

    def cast(type : T.class) : T* forall T
      @data.as(T*)
    end
  end
end
