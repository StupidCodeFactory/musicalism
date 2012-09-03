module Musicalism

  class Scale
    def initialize
      @interval_generator = Interval.new
    end

  end

end
require 'musicalism/scale/major'
require 'musicalism/scale/minor'
