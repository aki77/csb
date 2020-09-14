module Csb
  class Cols
    def col_pairs(item)
      headers.zip(values(item))
    end

    def as_table(items)
      [headers] + items.map { |item| values(item) }
    end
  end
end
