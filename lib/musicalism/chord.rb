module Musicalism
  class Chord
    attr_reader :notes

    def initialize(notes, options = {})
      @notes = notes
      inversion = options.delete(:inversion) || 0
      inverse! inversion if inversion > 0
    end

    def inverse(depth)
      self.class.new @notes.rotate(depth)
    end

    def inverse!(depth)
      @notes.rotate! depth
    end

    def ==(other)
      @notes == other.notes
    end
  end
end
