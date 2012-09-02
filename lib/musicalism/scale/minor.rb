module Musicalism
  
  # defaults to natural minor scale
  class MinorScale < Scale

    def second
      @interval_generator.major_second
    end

    def third
      @interval_generator.minor_third
    end

    def forth
      @interval_generator.perfect_forth
    end

    def fifth
      @interval_generator.perfect_fifth
    end

    def sixth
      @interval_generator.minor_sixth
    end

    def seventh
      @interval_generator.minor_seventh
    end

  end
end
