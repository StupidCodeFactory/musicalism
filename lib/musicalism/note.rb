require 'debug'
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

    LOWEST_MIDI_NODE_NUMBER = 21

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

      def notes_to_midi_map
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

      def each(&block)
        note = new('A0')
        (LOWEST_MIDI_NODE_NUMBER..128).each do |midi_note_number|
          pp midi_note_number
          block.call(note)
          note = note.next
        end
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
      ^(?<pitch>[a-g](?<alteration>\#|b){0,2})$
    /ix

    DEFAULT_CENTER_OCTAVE = 4

    def initialize(note)
      parsed_note_info = self.class.parse_note_and_alteration(note)
      self.pitch      = parsed_note_info[:pitch]
      self.octave     = parsed_note_info[:octave]
      self.alteration = parsed_note_info[:alteration]
      # raise UnkownNoteError, "#{note} is not a valid note" if pitch.nil? && octave.nil?
    end

    def next
      next_octave = octave
      matchdata = pitch.match(/^(?<p>[abcedfg])(?<alteration>#?)$/i)
      # matchdata ||= pitch.match(/^(?:[be])(?<alteration>#?)$/i)
      # alteration = matchdata && matchdata[:alteration]

      next_pitch_base = if matchdata && !alteration&.empty?
                          "#{pitch[0].next}"
                        else
                          "#{pitch[0]}"
                        end
      next_pitch = next_pitch_base

      next_octave += 1 if next_pitch_base.match?(/^c$/i)

      self.class.new("#{next_pitch}#{next_octave}")
    end

    def alteration
      @alteration ||= begin
        matchdata = pitch.match(/^[a-b](?<alteration>(?:\#|b){0,2})/i)
        return if matchdata.nil?

        matchdata[:alteration]
      end
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

    attr_writer :pitch, :octave, :alteration

    def note?(note)
      NOTES.flatten.include?(note)
    end

    def pitch_index
      NOTES.index { |a| a.include?(pitch) }
    end

    def next_pitch_changes_octave?
      pitch[0].match?(/^b$/i)
    end

    notes_to_midi_map
  end
end
