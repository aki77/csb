require 'csv'
require 'csb/cols'

module Csb
  class Builder
    UTF8_BOM = "\xEF\xBB\xBF".freeze

    attr_reader :output, :utf8_bom, :items, :cols, :csv_options
    attr_accessor :items

    def initialize(output = '', items: [], **kwargs)
      @output = output
      @cols = Cols.new
      @items = items
      @utf8_bom = kwargs.fetch(:utf8_bom) { Csb.configuration.utf8_bom }
      @csv_options = kwargs.fetch(:csv_options) { Csb.configuration.csv_options }
    end

    def build
      output << UTF8_BOM if utf8_bom
      output << CSV.generate_line(cols.headers, **csv_options) if write_headers?
      items.each do |item|
        output << CSV.generate_line(cols.values_by_item(item), **csv_options)
      rescue => error
        break if Csb.configuration.ignore_class_names.include?(error.class.name)

        raise error
      end
      output
    end

    private

    def write_headers?
      @csv_options.fetch(:write_headers, true)
    end
  end
end
