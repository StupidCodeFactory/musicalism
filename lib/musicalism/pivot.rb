module Musicalism
  Pivot = Data.define(:chord, :from_key, :from_numeral, :to_key, :to_numeral) do
    def to_s
      "#{chord}: #{from_numeral} in #{from_key} = #{to_numeral} in #{to_key}"
    end

    def inspect
      "#<#{self.class.name} #{self}>"
    end
  end
end
