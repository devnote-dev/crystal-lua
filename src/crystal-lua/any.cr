module Lua
  struct Any
    alias Type = Nil | Bool | Number::Primitive | String # | Reference | Table | Function | Callable | Coroutine

    getter raw : Type

    delegate :==, :===, :to_s, to: @raw

    def initialize(@raw : Type)
    end

    def as_bool : Bool
      @raw.as(Bool)
    end

    def as_bool? : Bool?
      @raw.as?(Bool)
    end

    {% for base in %w(8 16 32 64 128) %}
      def as_i{{base.id}} : Int{{ base.id }}
        @raw.as(Int{{ base.id }})
      end

      def as_i{{base.id}}? : Int{{ base.id }}?
        @raw.as?(Int{{ base.id }})
      end

      def as_u{{base.id}} : UInt{{ base.id }}
        @raw.as(UInt{{ base.id }})
      end

      def as_u{{base.id}}? : UInt{{ base.id }}?
        @raw.as?(UInt{{ base.id }})
      end
    {% end %}

    {% for base in %w(32 64) %}
      def as_f{{base.id}} : Float{{ base.id }}
        @raw.as(Float{{ base.id }})
      end

      def as_f{{base.id}}? : Float{{ base.id }}?
        @raw.as?(Float{{ base.id }})
      end
    {% end %}

    def as_s : String
      @raw.as(String)
    end

    def as_s? : String?
      @raw.as?(String)
    end
  end
end
