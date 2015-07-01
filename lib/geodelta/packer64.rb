# encoding: utf-8

require_relative "./packer_base"

module GeoDelta
  class Packer64 < PackerBase
    def initialize
      super(64, 3, 2, 5)
    end

    def pack_world_delta(id)
      return id << 59
    end

    def unpack_world_delta(value)
      return (value >> 59) & ((1 << @world_bits) - 1)
    end

    def pack_sub_delta(level, id)
      return id << (57 - ((level - 2) * 2))
    end

    def unpack_sub_delta(level, value)
      return (value >> (57 - ((level - 2) * 2))) & ((1 << @sub_bits) - 1)
    end
  end
end
