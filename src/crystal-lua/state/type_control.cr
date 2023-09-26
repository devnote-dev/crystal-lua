module Lua
  class State
    def is_boolean?(index : Int32) : Bool
      LibLua.type(@state, index).boolean?
    end

    def is_c_function?(index : Int32) : Bool
      LibLua.iscfunction(@state, index) != 0
    end

    def is_integer?(index : Int32) : Bool
      LibLua.isinteger(@state, index) != 0
    end

    def is_none?(index : Int32) : Bool
      LibLua.type(@state, index).none?
    end

    def is_none_or_nil?(index : Int32) : Bool
      type = LibLua.type(@state, index)
      type.none? || type == Type::Nil
    end

    def is_number?(index : Int32) : Bool
      LibLua.isnumber(@state, index) != 0
    end

    def is_string?(index : Int32) : Bool
      LibLua.isstring(@state, index) != 0
    end

    def is_table?(index : Int32) : Bool
      LibLua.type(@state, index).table?
    end

    def is_userdata?(index : Int32) : Bool
      LibLua.isuserdata(@state, index) != 0
    end

    def is_yieldable?(index : Int32) : Bool
      LibLua.isyieldable(@state, index) != 0
    end

    def to_boolean(index : Int32) : Bool
      LibLua.toboolean(@state, index) != 0
    end

    def to_c_function(index : Int32) : LibLua::CFunction
      LibLua.tocfunction(@state, index)
    end

    def to_close(index : Int32) : Nil
      LibLua.toclose(@state, index)
    end

    def to_integer(index : Int32) : Int32
      LibLua.tointeger(@state, index)
    end

    def to_string(index : Int32) : String
      String.new LibLua.tolstring(@state, index, nil)
    end

    def to_number(index : Int32) : Number
      LibLua.tonumberx(@state, index, nil)
    end

    def to_float(index : Int32) : Float64
      to_number(index).as(Float64)
    end

    def to_pointer(index : Int32) : Void*
      LibLua.topointer(@state, index)
    end

    def to_thread(index : Int32) : State
      State.new LibLua.tothread(@state, index)
    end

    def to_userdata(index : Int32, type : T.class) : T* forall T
      LibLua.touserdata(@state, index).as(T*)
    end
  end
end
