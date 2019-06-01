module Kugiru
  class Configuration
    attr_accessor :utf8_bom, :streaming, :after_streaming_error

    def initialize
      @utf8_bom = false
      @streaming = true
    end
  end
end
