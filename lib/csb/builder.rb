require 'csv'
require 'csb/cols'

module Csb
  class Builder
    UTF8_BOM = "\xEF\xBB\xBF".freeze

    attr_reader :output, :utf8_bom, :items, :cols, :csv_options
    attr_accessor :items

    def initialize(output = '', items: [], utf8_bom: false, csv_options: {})
      @output = output
      @utf8_bom = utf8_bom
      @cols = Cols.new
      @items = items
      @csv_options = csv_options
    end

    def build
      output << UTF8_BOM if utf8_bom
      output << CSV.generate_line(cols.headers, **csv_options)
      items.each do |item|
        output << CSV.generate_line(cols.values_by_item(item), **csv_options)
      rescue => error
        break if Csb.configuration.ignore_class_names.include?(error.class.name)

        raise error
      end
      output
    end
  end
end
