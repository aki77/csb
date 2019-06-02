require 'csv'

module Csb
  class Builder
    UTF8_BOM = "\xEF\xBB\xBF".freeze

    attr_reader :output, :utf8_bom, :cols, :data

    def initialize(output = '', cols:, data:, utf8_bom: false)
      @output = output
      @utf8_bom = utf8_bom
      @cols = cols
      @data = data
    end

    def build
      output << UTF8_BOM if utf8_bom
      output << CSV.generate_line(cols.keys)
      data.each do |row|
        values = cols.values.map { |pr| pr.call(row) }
        output << CSV.generate_line(values)
      end
      output
    end

    def self.build(**args)
      self.new(args).build
    end

    def self.build_enumerator(**args)
      Enumerator.new do |y|
        begin
          self.new(y, args).build
        rescue => error
          Csb.configuration.after_streaming_error.try(:call, error)
          raise error
        end
      end
    end
  end
end
