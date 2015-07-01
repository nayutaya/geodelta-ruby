# encoding: utf-8

require_relative "./delta_geometry"

module GeoDelta
  module HexGeometry
    HEX_POSITION = {
      [0, 0] => 0,
      [0, 1] => 3,
      [1, 0] => 1,
      [1, 1] => 2,
      [2, 0] => 4,
      [2, 1] => 5,
      [3, 0] => 3,
      [3, 1] => 0,
      [4, 0] => 2,
      [4, 1] => 1,
      [5, 0] => 5,
      [5, 1] => 4,
    }.freeze.tap { |h| h.keys.map(&:freeze) }

    def self.get_hex_position(ids)
      unit = get_unit(ids)
      x, y = GeoDelta::DeltaGeometry.get_center(ids)
      ix   = (x / unit * 2.0).floor % 6
      iy   = (y / unit      ).floor % 2
      return HEX_POSITION[[ix, iy]] || raise("BUG [#{i}, #{j}]")
    end

    def self.get_base_delta_ids(ids)
      unit = get_unit(ids)
      ux   = unit / 2.0
      uy   = unit / 3.0
      pos  = self.get_hex_position(ids)
      x, y = GeoDelta::DeltaGeometry.get_center(ids)

      sx, sy =
        case pos
        when 0 then [0.0, 0.0    ]
        when 1 then [-ux, +uy    ]
        when 2 then [-ux, +uy * 3]
        when 3 then [0.0, +uy * 4]
        when 4 then [+ux, +uy * 3]
        when 5 then [+ux, +uy    ]
        else raise "BUG [#{pos}]"
        end

      return nil if x + sx > +12.0
      return nil if x + sx < -12.0 + unit
      return nil if y + sy > +12.0
      return nil if y + sy < -12.0 + unit

      return GeoDelta::DeltaGeometry.get_delta_ids(x + sx, y + sy, ids.size)
    end

    def self.get_part_delta_ids(base_ids)
      level = base_ids.size
      unit  = get_unit(base_ids)
      x, y  = GeoDelta::DeltaGeometry.get_coordinates(base_ids)[1]

      x1 = x - (unit / 2.0)
      x2 = x
      x3 = x + (unit / 2.0)

      y1 = y + (unit * 2.0 / 3.0)
      y2 = y + (unit / 3.0)
      y3 = y - (unit / 3.0)
      y4 = y - (unit * 2.0 / 3.0)

      return [
        [x2, y1],
        [x3, y2],
        [x3, y3],
        [x2, y4],
        [x1, y3],
        [x1, y2],
      ].map { |xx, yy|
        GeoDelta::DeltaGeometry.get_delta_ids(xx, yy, level)
      }
    end

    def self.get_coordinates(base_ids)
      unit = get_unit(base_ids)
      u1   = unit
      u2   = unit / 2.0
      x, y = GeoDelta::DeltaGeometry.get_coordinates(base_ids)[1]

      return nil if y - u1 < -12.0

      return [
        [x     , y     ],
        [x + u2, y + u1],
        [x + u1, y     ],
        [x + u2, y - u1],
        [x - u2, y - u1],
        [x - u1, y     ],
        [x - u2, y + u1],
      ]
    end

    def self.get_unit(ids)
      level = ids.size
      return 12.0 / (2 ** (level - 1))
    end
    private_class_method :get_unit
  end
end
