module Lua
  class Buffer
    @buf : LibLua::Buffer

    def self.init_with_size(state : State, size : UInt32)
      ptr = LibLua.l_buffinitsize(state, out buf, size)
      String.new ptr[0..size]
    end

    def self.new(state : State)
      LibLua.l_buffinit(state, out buf)
      new buf
    end

    def initialize(@buf : LibLua::Buffer)
    end
  end
end
