# encoding: utf-8

require_relative "./packer_base"

module GeoDelta
  class Packer64 < PackerBase
    def initialize
      super(64, 3, 2, 5)
    end
  end
end
