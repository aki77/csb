# frozen_string_literal: true

require 'csv'

module Kugiru
  class Builder
    UTF8_BOM = "\xEF\xBB\xBF"

    attr_accessor :cols, :data, :filename
    attr_reader :output, :utf8_bom

    def initialize(output = '', utf8_bom: false)
      @output = output
      @cols = {}
      @data = []
      @utf8_bom = utf8_bom
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

    def build_enumerator
      Enumerator.new do |y|
        @output = y
        build
      end
    end
  end
end
