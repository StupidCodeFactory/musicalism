module Musicalism
  class Note
    class UnkownNoteError < ArgumentError; end

    NOTES = %w( A #A bA B #B bB C #C bC D #D bD E #E bE F #F bF G #G bG ).freeze
    NOTES_BIT = [
      ['A'],
      ['#A', 'bB'],
      ['B'],
      ['#B', 'C'],
      ['#C', 'bD'],
      ['D'],
      ['#D', 'bE'],
      ['E'],
      ['#E', 'F'],
      ['F'],
      ['#F', 'bG'],
      ['G'],
      ['#G', 'bA']
    ]

    def initialize note
      raise UnkownNoteError.new "#{note} is not a note" unless NOTES.include? note
      @pitch = note
    end
    
    def transpose interval
      debugger
      note_set_index = pitch_index + 1 + interval
      if NOTES_BIT.length < note_set_index
        NOTES_BIT.at(note_set_index)
      else
        
      end
    end

    private

    def pitch_index
      NOTES_BIT.index {|a| a.include?(@pitch) }
    end
  end
end