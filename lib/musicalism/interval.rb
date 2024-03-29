module Musicalism
  # Basic definitions of musical intervals
  class Interval
    SEMITONE = 1

    def perfect_unison
      0
    end
    alias diminished_second perfect_unison

    def minor_second
      SEMITONE
    end
    alias augmented_unison minor_second

    def major_second
      SEMITONE * 2
    end
    alias diminished_third major_second

    def minor_third
      SEMITONE * 3
    end
    alias augmented_second minor_third

    def major_third
      SEMITONE * 4
    end
    alias diminished_forth major_third

    def perfect_forth
      SEMITONE * 5
    end
    alias augmented_third perfect_forth

    def augmented_forth
      SEMITONE * 6
    end
    alias diminished_fifth augmented_forth

    def perfect_fifth
      SEMITONE * 7
    end
    alias diminished_sixth perfect_fifth

    def minor_sixth
      SEMITONE * 8
    end
    alias augmented_fith minor_sixth

    def major_sixth
      SEMITONE * 9
    end
    alias diminished_seventh major_sixth

    def minor_seventh
      SEMITONE * 10
    end
    alias augmented_sixth minor_seventh

    def major_seventh
      SEMITONE * 11
    end
    alias diminished_octave major_seventh

    def perfect_octave
      SEMITONE * 12
    end
  end
end
