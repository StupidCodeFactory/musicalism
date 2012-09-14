module Musicalism
  class Scale

    attr_reader :alterations
    attr_reader :root_note
    attr_reader :interval_generator

    def initialize root_note
      @root_note = root_note.is_a?(Note) ? root_note : Note.new(root_note)
      @interval_generator = Interval.new
      @alterations = []
      calcuate_alterations
    end
    
    def notes
      @notes = @scale_structure.inject [@root_note] do |scale, interval|
        # return an array of possible notes
        ap scale
        scale << @root_note.transpose(interval).detect do |n|
          next_pitch = scale[-1].pitch.gsub(/#|b/, '').next
          next_pitch = 'A' if next_pitch > 'G'
          n.pitch =~ /#{next_pitch}/
        end
      end
    end
    
    def calcuate_alterations
      scale = Musicalism::Note::NOTES.rotate 3
      fifth_circle_index = 0
      loop do
        break if scale.first.include? @root_note.pitch
        fifth_circle_index += 1
        scale = scale.rotate 7
      end

      scale = Musicalism::Note::NOTES.rotate 9
      1.upto(fifth_circle_index) do |variable|
        @alterations << scale.first
        scale = scale.rotate 7
      end
    end
  end

end
require 'musicalism/scale/major'
require 'musicalism/scale/minor'
