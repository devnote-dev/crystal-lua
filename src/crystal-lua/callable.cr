module Lua
  module Callable
    def self.export(state : Lua::State) : Nil
      data = state.new_userdata(sizeof(UInt64*), 1).as(UInt64*)
      data.value = self.object_id
      state.new_metatable self.class.name

      state.push "__gc"
      state.push ->Lua.__gc(LibLua::State)
      state.set_table -3

      # state.push "new"
      # state.push ->__new(LibLua::State)
      # state.set_table -3

      state.push "__crystal_type"
      state.push self.name
      state.set_table -3

      state.set_metatable -2
    end
  end
end
