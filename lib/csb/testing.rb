module Csb
  class Cols
    def col_pairs(item)
      headers.zip(values(item))
    end
  end
end
