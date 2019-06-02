module Csb
  class Col
    attr_reader :name

    def initialize(name, value = nil, &block)
      @name = name
      @value = block ? block : value
    end

    def value_by_item(item)
      case value
      when ::Symbol
        item.public_send(value)
      when ::Proc
        value.call(item)
      else
        value
      end
    end

    private

    attr_reader :value
  end
end
