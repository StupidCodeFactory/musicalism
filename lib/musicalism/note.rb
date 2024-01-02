require 'debug'
module Musicalism
  class Note
    include Comparable

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

    NOTE_PARSER = /
      ^(?<pitch>(?:(?:a|b)\#{0,2}|(?:bb{0,2})))(?<octave>0)$|
      ^(?<pitch>[a-g](?:\#|b){0,2})(?<octave>[1-6])$|
      ^(?<pitch>(?:c|d|e|f|g|a)(?:\#|b){0,2})(?<octave>7)$|
      ^(?<pitch>b\#?)(?<octave>7)$|
      ^(?<pitch>c(?:b{1,2})?)(?<octave>8)$|
      ^(?<pitch>[a-g](?:\#|b){0,2})$
    /ix

    DEFAULT_CENTER_OCTAVE = 4

    def initialize(note)
      matchdata = note.match(NOTE_PARSER)
      raise UnkownNoteError, "#{note} is not a valid note" if matchdata.nil?

      self.pitch = matchdata[:pitch].capitalize
      self.octave = Integer(matchdata[:octave] || DEFAULT_CENTER_OCTAVE)
      raise UnkownNoteError, "#{note} is not a valid note" if pitch.nil? && octave.nil?
    end

    def next
      return self.class.new("#{pitch.next}#{octave + 1}") if pitch.match?(/^b/i)

      self.class.new("#{pitch.next}#{octave}")
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

    def <=>(other)
      to_midi <=> other.to_midi
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
