module Musicalism
  class MelodicMinorScale < MinorScale
    private

    def scale_structure
      super[0..-3] + [interval_generator.major_sixth, interval_generator.major_seventh]
    end
  end
end
