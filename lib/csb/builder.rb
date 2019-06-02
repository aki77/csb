require 'csv'
require 'csb/cols'

module Csb
  class Builder
    UTF8_BOM = "\xEF\xBB\xBF".freeze

    attr_reader :output, :utf8_bom, :items, :cols
    attr_accessor :items

    def initialize(output = '', items: [], utf8_bom: false)
      @output = output
      @utf8_bom = utf8_bom
      @cols = Cols.new
      @items = items
    end

    def build
      output << UTF8_BOM if utf8_bom
      output << CSV.generate_line(cols.headers)
      items.each do |item|
        output << CSV.generate_line(cols.values_by_item(item))
      end
      output
    end
  end
end
