module Musicalism
  class Chord
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

    def to_midi
      notes.map(&:to_midi)
    end

    def ==(other)
      @notes == other.notes
    end
  end
end
