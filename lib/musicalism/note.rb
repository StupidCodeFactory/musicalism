module Musicalism
  class Note
    include Comparable

    class UnkownNoteError < ArgumentError; end

    attr_reader :pitch, :octave, :alteration

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

    LOWEST_MIDI_NOTE_NUMBER = 21
    HIGHEST_MIDI_NOTE_NUMBER = 108
    MIDI_NUMBER_OF_C0 = 12
    SEMITONES_PER_OCTAVE = 12
    NATURAL_SEMITONES_FROM_C = { 'C' => 0, 'D' => 2, 'E' => 4, 'F' => 5, 'G' => 7, 'A' => 9, 'B' => 11 }.freeze
    ALTERATION_SEMITONES = { '#' => 1, 'b' => -1 }.freeze
    SPELLINGS_FROM_C = NOTES.rotate(NOTES.index { |spellings| spellings.include?('C') }).freeze

    NOTE_PARTS = %i[pitch octave alteration]
    class << self
      def parse_note_and_alteration(string)
        matchdata = string.match(NOTE_PARSER)
        raise UnkownNoteError, "#{string} is not a valid note" if matchdata.nil?

        Hash[NOTE_PARTS.zip(matchdata.values_at(*NOTE_PARTS))].tap do |parts|
          parts[:pitch].capitalize!
          parts[:alteration] = nil if parts[:alteration] == ''
          parts[:octave] = Integer(parts[:octave] || DEFAULT_CENTER_OCTAVE)
        end
      end

      def each
        (LOWEST_MIDI_NOTE_NUMBER..HIGHEST_MIDI_NOTE_NUMBER).each { |midi_number| yield from_midi(midi_number) }
      end

      def from_midi(midi_number)
        octave, pitch_class = (midi_number - MIDI_NUMBER_OF_C0).divmod(SEMITONES_PER_OCTAVE)
        new("#{natural_or_sharp_spelling(SPELLINGS_FROM_C[pitch_class])}#{octave}")
      end

      private

      def natural_or_sharp_spelling(spellings)
        spellings.find { |name| name.match?(/\A[A-G]\z/) } ||
          spellings.find { |name| name.match?(/\A[A-G]#\z/) }
      end
    end

    NOTE_PARSER = /
      ^(?<pitch>a(?<alteration>\#{0,2}))(?<octave>0)$|
      ^(?<pitch>b(?<alteration>[\#b]{0,2}))(?<octave>0)$|
      ^(?<pitch>[a-g](?<alteration>[\#b]{0,2}))(?<octave>[1-6])$|
      ^(?<pitch>(?:[cdefga])(?<alteration>[\#b]{0,2}))(?<octave>7)$|
      ^(?<pitch>b(?<alteration>\#)?)(?<octave>7)$|
      ^(?<pitch>b(?<alteration>b{1,2}?))(?<octave>7)$|
      ^(?<pitch>c(?<alteration>b{1,2})?)(?<octave>8)$|
      ^(?<pitch>[a-g](?<alteration>[\#b]{0,2}))$
    /ix

    DEFAULT_CENTER_OCTAVE = 4

    def initialize(note, octave = nil)
      parsed_note_info = self.class.parse_note_and_alteration("#{note}#{octave}")
      self.pitch      = parsed_note_info[:pitch]
      self.octave     = parsed_note_info[:octave]
      self.alteration = parsed_note_info[:alteration]
    end

    def next
      self.class.from_midi(to_midi + 1)
    end

    def letter
      pitch[0]
    end

    def up_an_octave
      self.class.new(pitch, octave + 1)
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
      MIDI_NUMBER_OF_C0 + (octave * SEMITONES_PER_OCTAVE) + semitones_above_c
    end

    def <=>(other)
      to_midi <=> other.to_midi
    end

    private

    attr_writer :pitch, :octave, :alteration

    def note?(note)
      NOTES.flatten.include?(note)
    end

    def pitch_index
      NOTES.index { |a| a.include?(pitch) }
    end

    def semitones_above_c
      NATURAL_SEMITONES_FROM_C.fetch(letter) + alteration_semitones
    end

    def alteration_semitones
      pitch[1..].each_char.sum { |sign| ALTERATION_SEMITONES.fetch(sign) }
    end
  end
end
