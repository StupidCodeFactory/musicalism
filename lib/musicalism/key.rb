module Musicalism
  class Key
    MODES = %i[major minor].freeze
    ROMAN_NUMERALS = %w[I II III IV V VI VII].freeze
    HARMONIC_FUNCTIONS = {
      tonic: %w[I VI III],
      subdominant: %w[IV II VI],
      dominant: %w[V VII]
    }.freeze
    DEGREES_FROM_HARMONIC_MINOR = %i[dominant subtonic].freeze

    attr_reader :tonic, :mode

    class << self
      def major(tonic)
        new(tonic, :major)
      end

      def minor(tonic)
        new(tonic, :minor)
      end

      def [](name)
        tonic, mode = name.split
        new(tonic, mode.to_s.downcase.to_sym)
      end
    end

    def initialize(tonic, mode)
      raise ArgumentError, "#{mode} is not a key mode, use major or minor" unless MODES.include?(mode)

      @tonic = tonic.is_a?(Note) ? tonic : Note.new(tonic)
      @mode = mode
    end

    def major?
      mode == :major
    end

    def minor?
      mode == :minor
    end

    def scale
      @scale ||= (major? ? MajorScale : MinorScale).new(tonic)
    end

    def signature
      scale.alterations
    end

    def relative
      major? ? Key.minor(scale.notes[5].down_an_octave) : Key.major(scale.notes[2])
    end

    def parallel
      Key.new(tonic, major? ? :minor : :major)
    end

    def dominant_key
      neighbour_on_circle_of_fifths(scale.notes[4])
    end

    def subdominant_key
      neighbour_on_circle_of_fifths(scale.notes[3])
    end

    def note(degree)
      raise ArgumentError, "degree must be 1 or more, got #{degree}" if degree < 1

      octaves_up, index = (degree - 1).divmod(scale.notes.size)
      octaves_up.times.reduce(scale.notes[index]) { |note, _| note.up_an_octave }
    end

    def chord(numeral, inversion: 0)
      degree = Scale::DEGREES.fetch(degree_index(numeral))
      scale_for(degree).degree_chord(degree, inversion: inversion)
    end

    def chords(harmonic_function = nil)
      numerals_for(harmonic_function).map { |numeral| chord(numeral) }
    end

    def ==(other)
      other.is_a?(Key) && tonic.pitch == other.tonic.pitch && mode == other.mode
    end

    def to_s
      "#{tonic.pitch} #{mode}"
    end

    def inspect
      "#<#{self.class.name} #{self}>"
    end

    private

    def neighbour_on_circle_of_fifths(note)
      Key.new(Note.new(note.pitch, tonic.octave), mode)
    end

    def scale_for(degree)
      minor? && DEGREES_FROM_HARMONIC_MINOR.include?(degree) ? HarmonicMinorScale.new(tonic) : scale
    end

    def degree_index(numeral)
      ROMAN_NUMERALS.index(numeral.to_s.upcase) ||
        raise(ArgumentError, "#{numeral} is not a roman numeral between I and VII")
    end

    def numerals_for(harmonic_function)
      return ROMAN_NUMERALS if harmonic_function.nil?

      HARMONIC_FUNCTIONS.fetch(harmonic_function) do
        raise ArgumentError, "#{harmonic_function} is not a harmonic function, use tonic, subdominant or dominant"
      end
    end
  end
end
