module Musicalism
  class Scale
    attr_reader :alterations, :root_note, :interval_generator

    DEGREES = %i[
      tonic
      supertonic
      mediant
      subdominant
      dominant
      submediant
      subtonic
    ].freeze

    def initialize(root_note)
      @root_note = root_note.is_a?(Note) ? root_note : Note.new(root_note)
      @interval_generator = Interval.new
      @alterations = []
      calcuate_alterations
    end

    # TODO: cache this mofos!
    def tonic_chord(options = {})
      @tonic_chord ||= Chord.new(tertian_from(:tonic), options)
    end

    def supertonic_chord(options = {})
      @supertonic_chord ||= Chord.new tertian_from(:supertonic), options
    end

    def mediant_chord(options = {})
      @mediant_chord ||= Chord.new tertian_from(:mediant), options
    end

    def subdominante_chord(options = {})
      @subdominante_chord ||= Chord.new tertian_from(:subdominant), options
    end

    def dominante_chord(options = {})
      @dominante_chord ||= Chord.new tertian_from(:dominant), options
    end

    def submediant_chord(options = {})
      @submediant_chord ||= Chord.new tertian_from(:submediant), options
    end

    def subtonic_chord(options = {})
      @subtonic_chord ||= Chord.new tertian_from(:subtonic), options
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
      1.upto(fifth_circle_index) do |_variable|
        @alterations << scale.first
        scale = scale.rotate 7
      end
    end

    private

    def tertian_from(degree)
      [0, 2, 4].each_with_object([]) do |i, chord_notes|
        chord_notes << notes.rotate(DEGREES.index(degree)).rotate(i).first
      end
    end
  end
end
require 'musicalism/scale/major'
require 'musicalism/scale/minor'
