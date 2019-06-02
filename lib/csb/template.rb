module Csb
  class Template < Builder
    attr_accessor :utf8_bom, :filename, :streaming, :items
    attr_reader :cols

    def initialize(utf8_bom:, streaming:)
      @utf8_bom = utf8_bom
      @streaming = streaming
      @cols = Cols.new
      @items = []
    end

    def build_string
      builder = Builder.new(utf8_bom: utf8_bom, items: items)
      builder.cols.copy!(cols)
      builder.build
    end

    def build_enumerator
      Enumerator.new do |y|
        begin
          builder = Builder.new(y, utf8_bom: utf8_bom, items: items)
          builder.cols.copy!(cols)
          builder.build
        rescue => error
          Csb.configuration.after_streaming_error.try(:call, error)
          raise error
        end
      end
    end
  end
end
