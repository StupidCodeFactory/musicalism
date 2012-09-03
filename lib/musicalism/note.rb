module Musicalism
  class Note
    class UnkownNoteError < ArgumentError; end

    attr_reader :pitch
    
    NOTES = [
      ['A'],
      ['#A', 'bB'],
      ['B',  'bC'],
      ['C',  '#B'],
      ['#C', 'bD'],
      ['D'],
      ['#D', 'bE'],
      ['E',  'bF'],
      ['F',  '#E'],
      ['#F', 'bG'],
      ['G'],
      ['#G', 'bA']
      ].freeze

    # CIRCLE_OF_FIFTH = NOTES.ma
    def initialize note
      raise UnkownNoteError.new "#{note} is not a note" unless is_note? note
      @pitch = note
    end
    
    def transpose interval
      new_note_index = pitch_index + interval
      if NOTES.length < new_note_index 
        new_pitches = NOTES[new_note_index]
      else
        new_pitches = NOTES[new_note_index - NOTES.length]
      end
      new_pitches.map { |p| self.class.new p } 
    end

    def == other_note
      pitch == other_note.pitch
    end

    private

    def is_note? note
      NOTES.flatten.include? note
    end

    def pitch_index
      NOTES.index {|a| a.include? @pitch }
    end
  end
end