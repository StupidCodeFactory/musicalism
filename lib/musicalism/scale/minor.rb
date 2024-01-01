module Musicalism
  # defaults to natural minor scale
  class MinorScale < Scale
    def initialize(pitch)
      super pitch
      @scale_structure = [
        @interval_generator.major_second,
        @interval_generator.minor_third,
        @interval_generator.perfect_forth,
        @interval_generator.perfect_fifth,
        @interval_generator.minor_sixth,
        @interval_generator.minor_seventh
      ]
    end
  end
end
require 'musicalism/scale/minor/harmonic'
require 'musicalism/scale/minor/melodic'
