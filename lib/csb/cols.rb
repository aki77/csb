require 'active_support/core_ext/object/deep_dup'
require 'csb/col'

module Csb
  class Cols
    include Enumerable

    attr_reader :cols

    def initialize
      @cols = []
    end

    def copy!(other)
      @cols = other.cols.deep_dup
    end

    def each(&block)
      cols.each(&block)
    end

    def add(*args, &block)
      cols << Col.new(*args, &block)
    end

    def headers
      map(&:name)
    end

    def values_by_item(item, *args)
      map do |col|
        col.value_by_item(item, *args)
      end
    end
  end
end
