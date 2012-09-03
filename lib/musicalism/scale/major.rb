module Musicalism

  class MajorScale < Scale
    def second
      @root_note.transpose @interval_generator.major_second
    end

    def third
      @root_note.transpose @interval_generator.major_third
    end

    def forth
      @root_note.transpose @interval_generator.perfect_forth
    end

    def fifth
      @root_note.transpose @interval_generator.perfect_fifth
    end

    def sixth
      @root_note.transpose @interval_generator.major_sixth
    end

    def seventh
      @root_note.transpose @interval_generator.major_seventh
    end

  end
end