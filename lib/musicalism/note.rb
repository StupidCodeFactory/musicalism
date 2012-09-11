module Musicalism
  class Note
    class UnkownNoteError < ArgumentError; end

    attr_reader :pitch
    
    NOTES = [
      ['##G', 'A', 'bbB'],
      ['#A',  'bB', 'bbC'],
      ['##A', 'B',  'bC'],
      ['#B',  'C',  'bbD'],
      ['##B', '#C', 'bD'],
      ['##C', 'D',  'bbE'],
      ['#D',  'bE'],
      ['##D', 'E',  'bF'],
      ['F',   '#E', 'bbG'],
      ['##E', '#F', 'bG'],
      ['##F', 'G', 'bbA'],
      ['#G', 'bA']
    ]

    CIRCLE_OF_FIFTH = []

    def initialize note
      raise UnkownNoteError.new "#{note} is not a note" unless is_note? note
      @pitch = note
    end
    
    def transpose interval
      new_note_index = pitch_index + interval

      new_pitches = if NOTES.length > new_note_index 
        NOTES[new_note_index]
      else
        NOTES[new_note_index - NOTES.length]
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