module Csb
  class Template
    attr_accessor :utf8_bom, :filename, :streaming, :items, :cols

    def initialize(utf8_bom:, streaming:)
      @utf8_bom = utf8_bom
      @streaming = streaming
      @cols = Cols.new
      @items = []
    end

    def build
      streaming ? build_enumerator : build_string
    end

    def streaming?
      !!streaming
    end

    private

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
          if Csb.configuration.after_streaming_error.respond_to?(:call)
            Csb.configuration.after_streaming_error.call(error)
          end
          raise error
        end
      end
    end
  end
end
