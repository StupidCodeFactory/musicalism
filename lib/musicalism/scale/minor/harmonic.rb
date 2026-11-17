module Musicalism
  class HarmonicMinorScale < MinorScale
    private

    def scale_structure
      super[0..-2] + [interval_generator.major_seventh]
    end
  end
end
