module Musicalism

  class MajorScale < Scale
    def second
      @interval_generator.major_second
    end

    def third
      @interval_generator.major_third
    end

    def forth
      @interval_generator.perfect_forth
    end

    def fifth
      @interval_generator.perfect_fifth
    end

    def sixth
      @interval_generator.major_sixth
    end

    def seventh
      @interval_generator.major_seventh
    end

  end
end