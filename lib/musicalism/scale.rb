module Musicalism
  class Scale

    attr_reader :alterations
    attr_reader :root_note
    attr_reader :interval_generator

    DEGREES = [
      :tonic,
      :supertonic,
      :mediant,
      :subdominant,
      :dominant,
      :submediant,
      :subtonic
    ].freeze

    def initialize root_note
      @root_note = root_note.is_a?(Note) ? root_note : Note.new(root_note)
      @interval_generator = Interval.new
      @alterations = []
      calcuate_alterations
    end

    def tonic_chord
      @tonic_chord ||= tertian_from :tonic
    end

    def supertonic_chord
      @supertonic_chord ||= tertian_from :supertonic
    end

    def mediant_chord
      @mediant_chord ||= tertian_from :mediant
    end

    def subdominante_chord
      @subdominante_chord ||= tertian_from :subdominant
    end

    def dominante_chord
      @dominante_chord ||= tertian_from :dominant
    end

    def submediant_chord
      @submediant_chord ||= tertian_from :submediant
    end

    def subtonic_chord
      @subtonic_chord ||= tertian_from :subtonic
    end

    def notes
      @notes ||= @scale_structure.inject [@root_note] do |scale, interval|
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

    private
    
    def tertian_from degree
      [0, 2, 4].inject([]) do |chord_notes, i|
        chord_notes << notes.rotate(DEGREES.index(degree)).rotate(i).first
        chord_notes
      end
    end
  end

end
require 'musicalism/scale/major'
require 'musicalism/scale/minor'
