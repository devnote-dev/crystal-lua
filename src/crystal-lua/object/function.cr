module Lua
  class Function < Lua::Object
    def call(*args : Any::Type) : Array(Any)
      preload do |pos|
        @state.call_and_return pos, args
      end
    end
  end
end
