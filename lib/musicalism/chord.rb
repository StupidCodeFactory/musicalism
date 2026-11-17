module Musicalism
  class Chord
    TRIAD_QUALITIES = {
      [4, 3] => :major,
      [3, 4] => :minor,
      [3, 3] => :diminished,
      [4, 4] => :augmented
    }.freeze

    attr_reader :notes

    def initialize(notes, options = {})
      @notes = notes
      inversion = options.delete(:inversion) || 0
      inverse! inversion if inversion > 0
    end

    def inverse(depth)
      self.class.new(@notes.dup, inversion: depth)
    end

    def inverse!(depth)
      depth.times { @notes.push(@notes.shift.up_an_octave) }
    end

    def quality
      TRIAD_QUALITIES[root_position&.intervals]
    end

    def root
      root_position&.notes&.first
    end

    def spelling
      notes.map(&:pitch)
    end

    def to_midi
      notes.map(&:to_midi)
    end

    def ==(other)
      @notes == other.notes
    end

    def to_s
      quality ? "#{root.pitch} #{quality}" : spelling.join(' ')
    end

    def inspect
      "#<#{self.class.name} #{notes.map { |note| "#{note.pitch}#{note.octave}" }.join(' ')}>"
    end

    protected

    def intervals
      notes.each_cons(2).map { |lower, upper| upper.to_midi - lower.to_midi }
    end

    private

    def root_position
      (0...notes.size).map { |depth| inverse(depth) }.find { |rotation| TRIAD_QUALITIES.key?(rotation.intervals) }
    end
  end
end
