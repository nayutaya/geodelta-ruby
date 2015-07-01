# encoding: utf-8

module GeoDelta
  module DeltaGeometry
    # 指定された座標(x,y)に該当するワールドデルタの番号を返す
    # ただし、-12.0 <= x <= +12.0、-12.0 <= y <= +12.0
    def self.get_world_delta_id(x, y)
      xx = x % 24
      yy = y.abs
      return (y >= 0.0 ? 0 : 4) +
        case
        when yy >= +2.0 * (xx -  0.0) then 0
        when yy <= -2.0 * (xx - 12.0) then 1
        when yy >= +2.0 * (xx - 12.0) then 2
        when yy <= -2.0 * (xx - 24.0) then 3
        else                               0
        end
    end

    # 指定された座標(x,y)に該当する上向きのサブデルタの番号を返す
    # ただし、0.0 <= x <= +12.0、0.0 <= y <= +12.0
    def self.get_upper_delta_id(x, y)
      case
      when y < -2.0 * (x - 6.0) then 3
      when y < +2.0 * (x - 6.0) then 2
      when y > 6.0              then 1
      else                           0
      end
    end

    # 指定された座標(x,y)に該当する下向きのサブデルタの番号を返す
    # ただし、0.0 <= x <= +12.0、0.0 <= y <= +12.0
    def self.get_lower_delta_id(x, y)
      case
      when y > -2.0 * (x - 12.0) then 3
      when y > +2.0 * x          then 2
      when y < 6.0               then 1
      else                            0
      end
    end

    # 指定されたワールドデルタが上向きかどうかを返す
    def self.upper_world_delta?(id)
      return (id % 2 == (id < 4 ? 1 : 0))
    end

    # 指定されたサブデルタが上向きかどうか返す
    def self.upper_sub_delta?(parent_is_upper, id)
      return (parent_is_upper ? (id != 0) : (id == 0))
    end

    def self.upper_delta?(ids)
      return ids.inject(nil) { |upper, id|
        if upper.nil?
          self.upper_world_delta?(id)
        else
          self.upper_sub_delta?(upper, id)
        end
      }
    end

    TRANSFORM_WORLD_DELTA_X = [+6.0, +0.0, -6.0, -12.0,  +6.0,  +0.0,  -6.0, -12.0].freeze
    TRANSFORM_WORLD_DELTA_Y = [+0.0, +0.0, +0.0,  +0.0, +12.0, +12.0, +12.0, +12.0].freeze

    def self.transform_world_delta(id, x, y)
      xx = (x + TRANSFORM_WORLD_DELTA_X[id]) % 12
      yy = (y + TRANSFORM_WORLD_DELTA_Y[id]) % 12
      return [xx, yy]
    end

    TRANSFORM_UPPER_DELTA_X = [-3.0, -3.0, -6.0, -0.0].freeze
    TRANSFORM_UPPER_DELTA_Y = [-0.0, -6.0, -0.0, -0.0].freeze

    def self.transform_upper_delta(id, x, y)
      xx = (x + TRANSFORM_UPPER_DELTA_X[id]) * 2
      yy = (y + TRANSFORM_UPPER_DELTA_Y[id]) * 2
      return [xx, yy]
    end

    TRANSFORM_LOWER_DELTA_X = [-3.0, -3.0, -0.0, -6.0].freeze
    TRANSFORM_LOWER_DELTA_Y = [-6.0, -0.0, -6.0, -6.0].freeze

    def self.transform_lower_delta(id, x, y)
      xx = (x + TRANSFORM_LOWER_DELTA_X[id]) * 2
      yy = (y + TRANSFORM_LOWER_DELTA_Y[id]) * 2
      return [xx, yy]
    end

    def self.get_delta_ids(x, y, level)
      ids    = [self.get_world_delta_id(x, y)]
      xx, yy = self.transform_world_delta(ids.last, x, y)
      upper  = self.upper_world_delta?(ids.last)

      (level - 1).times {
        if upper
          ids   << self.get_upper_delta_id(xx, yy)
          xx, yy = self.transform_upper_delta(ids.last, xx, yy)
          upper  = self.upper_sub_delta?(upper, ids.last)
        else
          ids   << self.get_lower_delta_id(xx, yy)
          xx, yy = self.transform_lower_delta(ids.last, xx, yy)
          upper  = self.upper_sub_delta?(upper, ids.last)
        end
      }

      return ids
    end

    WORLD_DELTA_CENTER = {
      0 => [ +0.0, +8.0],
      1 => [ +6.0, +4.0],
      2 => [+12.0, +8.0],
      3 => [+18.0, +4.0],
      4 => [ +0.0, -8.0],
      5 => [ +6.0, -4.0],
      6 => [+12.0, -8.0],
      7 => [+18.0, -4.0],
    }.freeze.tap { |h| h.values.map(&:freeze) }

    def self.get_world_delta_center(id)
      return WORLD_DELTA_CENTER[id]
    end

    UPPER_SUB_DELTA_DISTANCE = {
      0 => [+0.0, +0.0],
      1 => [+0.0, +4.0],
      2 => [+3.0, -2.0],
      3 => [-3.0, -2.0],
    }.freeze.tap { |h| h.values.map(&:freeze) }

    def self.get_upper_sub_delta_distance(id)
      return UPPER_SUB_DELTA_DISTANCE[id]
    end

    LOWER_SUB_DELTA_DISTANCE = {
      0 => [+0.0, +0.0],
      1 => [+0.0, -4.0],
      2 => [-3.0, +2.0],
      3 => [+3.0, +2.0],
    }.freeze.tap { |h| h.values.map(&:freeze) }

    def self.get_lower_sub_delta_distance(id)
      return LOWER_SUB_DELTA_DISTANCE[id]
    end

    def self.get_sub_delta_distance(parent_is_upper, id)
      if parent_is_upper
        return self.get_upper_sub_delta_distance(id)
      else
        return self.get_lower_sub_delta_distance(id)
      end
    end

    def self.get_center(ids)
      w_id, *s_ids = ids

      x, y  = self.get_world_delta_center(w_id)
      upper = self.upper_world_delta?(w_id)
      xs = [x]
      ys = [y]

      s_ids.each.with_index { |id, index|
        x, y  = self.get_sub_delta_distance(upper, id)
        upper = self.upper_sub_delta?(upper, id)
        xs << (x / (2 ** index))
        ys << (y / (2 ** index))
      }

      x = xs.sort.inject(0.0, &:+)
      y = ys.sort.inject(0.0, &:+)

      x -= 24.0 if x > 12.0

      return [x, y]
    end

    def self.get_coordinates(ids)
      cx, cy = self.get_center(ids)
      level  = ids.size
      sign   = (self.upper_delta?(ids) ? +1 : -1)
      scale  = 1.0 / (2 ** (level - 1)) * sign

      dx1 = 0.0
      dy1 = 8.0 * scale
      dx2 = 6.0 * scale
      dy2 = 4.0 * scale

      return [
        [cx,       cy      ],
        [cx + dx1, cy + dy1],
        [cx + dx2, cy - dy2],
        [cx - dx2, cy - dy2],
      ]
    end
  end
end
