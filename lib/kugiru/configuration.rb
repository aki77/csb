module Kugiru
  class Configuration
    attr_accessor :utf8_bom

    def initialize
      @utf8_bom = false
    end
  end
end
