# encoding: utf-8

require_relative "./packer_base"

module GeoDelta
  class Packer32 < PackerBase
    def initialize
      super(32, 3, 2, 4)
    end
  end
end
