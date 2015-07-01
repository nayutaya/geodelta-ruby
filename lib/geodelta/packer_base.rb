# encoding: utf-8

module GeoDelta
  class PackerBase
    def initialize(total_bits, world_bits, sub_bits, level_bits)
      @total_bits = total_bits
      @world_bits = world_bits
      @sub_bits   = sub_bits
      @level_bits = level_bits

      @sub_count   = ((@total_bits - @world_bits - @level_bits - 1) / @sub_bits.to_f).floor
      @sub_mask    = ((1 << @sub_bits) - 1)
      @world_mask  = ((1 << @world_bits) - 1)
      @world_shift = (@sub_count * @sub_bits) + @level_bits
    end

    def pack_world_delta(id)
      return id << @world_shift
    end

    def unpack_world_delta(value)
      return (value >> @world_shift) & @world_mask
    end

    def pack_sub_delta(level, id)
      return id << (@world_shift - ((level - 1) * @sub_bits))
    end

    def unpack_sub_delta(level, value)
      return (value >> (@world_shift - ((level - 1) * @sub_bits))) & @sub_mask
    end

    def pack_level(level)
      return level
    end

    def unpack_level(value)
      @_level_mask ||= ((1 << @level_bits) - 1)
      return value & @_level_mask
    end

    def pack(ids)
      wid   = self.pack_world_delta(ids[0])
      sids  = ids[1..-1].each_with_index.map { |id, i| self.pack_sub_delta(i + 2, id) }.inject(0, &:+)
      level = self.pack_level(ids.size)
      return wid + sids + level
    end

    def unpack(value)
      level = self.unpack_level(value)
      wid   = self.unpack_world_delta(value)
      sids  = (level - 1).times.map { |i| self.unpack_sub_delta(i + 2, value) }
      return [wid] + sids
    end
  end
end
