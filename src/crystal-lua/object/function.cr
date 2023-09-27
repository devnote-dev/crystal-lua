module Lua
  class Function < Lua::Object
    def call(*args : Any::Type) : Any?
      preload do |pos|
        args.each { |arg| @state.push arg }
        @state.protected_call args.size, 1, 0
        @state.pop
      end
    end
  end
end
