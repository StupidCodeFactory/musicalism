module Musicalism

  class Scale
    def initialize root_note
      @root_note = root_note.is_a?(Note) ? root_note : Note.new(root_note)
      @interval_generator = Interval.new
    end
    
    def notes
      [ @root_note, second, third, forth, fifth, sixth, seventh ]
    end
  end

end
require 'musicalism/scale/major'
require 'musicalism/scale/minor'
