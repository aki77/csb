module Csb
  class Configuration
    attr_accessor :utf8_bom, :streaming, :after_streaming_error, :ignore_class_names, :csv_options

    def initialize
      @utf8_bom = false
      @streaming = true
      @csv_options = {}
      @ignore_class_names = %w[Puma::ConnectionError]
    end
  end
end
