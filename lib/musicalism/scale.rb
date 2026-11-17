module Musicalism
  class Scale
    attr_reader :root_note, :interval_generator

    DEGREES = %i[
      tonic
      supertonic
      mediant
      subdominant
      dominant
      submediant
      subtonic
    ].freeze

    LETTERS = %w[C D E F G A B].freeze
    ORDER_OF_SHARPS = %w[F C G D A E B].freeze
    ORDER_OF_FLATS = ORDER_OF_SHARPS.reverse.freeze

    def initialize(root_note)
      @root_note = root_note.is_a?(Note) ? root_note : Note.new(root_note)
      @interval_generator = Interval.new
    end

    def notes
      @notes ||= scale_structure.each_with_object([root_note]) do |semitones_from_root, scale|
        scale << next_degree_note(scale.last, semitones_from_root)
      end
    end

    def alterations
      flats, sharps = notes.map(&:pitch).select { |pitch| pitch.length > 1 }.partition { |pitch| pitch.end_with?('b') }
      flats.sort_by { |pitch| ORDER_OF_FLATS.index(pitch[0]) } + sharps.sort_by { |pitch| ORDER_OF_SHARPS.index(pitch[0]) }
    end

    def degree_chord(degree, options = {})
      Chord.new(tertian_from(DEGREES.index(degree)), options)
    end

    private

    def tertian_from(degree_index)
      notes_over_two_octaves.values_at(degree_index, degree_index + 2, degree_index + 4)
    end

    def notes_over_two_octaves
      notes + notes.map(&:up_an_octave)
    end

    def next_degree_note(previous_note, semitones_from_root)
      letter = LETTERS[(LETTERS.index(previous_note.letter) + 1) % LETTERS.size]
      pitch = root_note.transpose(semitones_from_root).map(&:pitch).find { |spelling| spelling.start_with?(letter) }
      Note.new(pitch, letter == 'C' ? previous_note.octave + 1 : previous_note.octave)
    end
  end
end
require 'musicalism/scale/major'
require 'musicalism/scale/minor'
