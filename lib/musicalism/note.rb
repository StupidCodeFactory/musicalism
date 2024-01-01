module Musicalism
  class Note
    class UnkownNoteError < ArgumentError; end

    attr_reader :pitch, :octave

    NOTES = [
      ['G##', 'A', 'Bbb'],
      ['A#',  'Bb', 'Cbb'],
      ['A##', 'B',  'Cb'],
      ['B#',  'C',  'Dbb'],
      ['B##', 'C#', 'Db'],
      ['C##', 'D',  'Ebb'],
      ['D#',  'Eb'],
      ['D##', 'E',  'Fb'],
      ['F',   'E#', 'Gbb'],
      ['E##', 'F#', 'Gb'],
      ['F##', 'G',  'Abb'],
      ['G#',  'Ab']
    ]

    CIRCLE_OF_FIFTH = []

    def self.notes_to_midi_map
      @@notes_to_midi_map ||= begin
        c_index = NOTES.index { |n| n.include? 'C' }
        notes = NOTES[c_index..-1] + NOTES[0..(c_index - 1)]
        h = {}
        counter = 0
        128.times do |i|
          notes.first.each do |n|
            h[n] ||= []
            h[n] << i
          end
          notes.rotate!
          counter += 1 if (i % 12).zero?
        end

        h.freeze
      end
    end

    def initialize(note, octave = 3)
      raise UnkownNoteError, "#{note} is not a valid note" unless note?(note)

      self.pitch = note
      self.octave = octave
    end

    def interval_from(note)
      target_index = NOTES.index { |a| a.include?(note.pitch) }
      self_index = NOTES.index { |a| a.include?(pitch) }
      if self_index > target_index
        self_index - target_index
      elsif (target_index % 12).zero?
        0
      else
        target_index - self_index
      end
    end

    def transpose(interval)
      new_note_index = pitch_index + interval

      new_pitches = if NOTES.length > new_note_index
                      NOTES[new_note_index]
                    else
                      NOTES[new_note_index - NOTES.length]
                    end

      new_pitches.map { |p| self.class.new p }
    end

    def to_midi
      self.class.notes_to_midi_map[pitch][octave - 1]
    end

    # maybe note with same pitch but different octave could be equal-ish
    def ==(other)
      pitch == other.pitch && octave == other.octave
    end

    private

    attr_writer :pitch, :octave

    def note?(note)
      NOTES.flatten.include?(note)
    end

    def pitch_index
      NOTES.index { |a| a.include?(pitch) }
    end

    notes_to_midi_map
  end
end
