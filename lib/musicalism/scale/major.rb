module Musicalism
  class MajorScale < Scale
    private

    def scale_structure
      [
        interval_generator.major_second,
        interval_generator.major_third,
        interval_generator.perfect_forth,
        interval_generator.perfect_fifth,
        interval_generator.major_sixth,
        interval_generator.major_seventh
      ]
    end
  end
end
