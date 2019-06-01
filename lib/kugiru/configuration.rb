module Kugiru
  class Configuration
    attr_accessor :utf8_bom, :streaming

    def initialize
      @utf8_bom = false
      @streaming = true
    end
  end
end
