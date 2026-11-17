require 'spec_helper'

RSpec.describe Musicalism::Chord do
  def chord_of(names)
    described_class.new(names.split.map { |name| Musicalism::Note.new(name) })
  end

  describe '#quality, #root and #to_s' do
    {
      'D4 F#4 A4' => ['D', :major, 'D major'],
      'F#4 A4 D5' => ['D', :major, 'D major'],
      'A4 C5 E5' => ['A', :minor, 'A minor'],
      'B4 D5 F5' => ['B', :diminished, 'B diminished'],
      'C4 E4 G#4' => ['C', :augmented, 'C augmented']
    }.each do |names, (root, quality, name)|
      it "names #{names} #{name}" do
        expect(chord_of(names)).to have_attributes(root: have_attributes(pitch: root), quality: quality, to_s: name)
      end
    end

    it 'lists the pitches of a chord that is not a triad' do
      expect(chord_of('C4 D4 E4')).to have_attributes(quality: nil, root: nil, to_s: 'C D E')
    end
  end

  describe '#voiced_near' do
    {
      ['A4 C5 E5', 'C4 E4 G4'] => 'C4 E4 A4',
      ['D5 F#5 A5', 'C4 E4 A4'] => 'D4 F#4 A4',
      ['G4 B4 D5', 'D4 F#4 A4'] => 'D4 G4 B4',
      ['C4 E4 G4', 'C4 E4 G4'] => 'C4 E4 G4'
    }.each do |(chord, previous), voicing|
      it "voices #{chord} as #{voicing} after #{previous}" do
        expect(chord_of(chord).voiced_near(chord_of(previous))).to eq(chord_of(voicing))
      end
    end

    it 'compares with the previous chord whatever order its notes are listed in' do
      expect(chord_of('A4 C5 E5').voiced_near(chord_of('G4 C4 E4'))).to eq(chord_of('C4 E4 A4'))
    end

    it 'keeps the chord itself' do
      expect(chord_of('A4 C5 E5').voiced_near(chord_of('C4 E4 G4'))).to have_attributes(to_s: 'A minor')
    end

    it 'skips voicings that would leave the piano range' do
      expect(chord_of('G6 B6 D7').voiced_near(chord_of('G6 B6 D7'))).to eq(chord_of('G6 B6 D7'))
    end
  end

  describe '.voice_lead' do
    it 'voices each chord near the one before it' do
      chords = ['C4 E4 G4', 'A4 C5 E5', 'D5 F#5 A5', 'G4 B4 D5'].map { |names| chord_of(names) }

      expect(described_class.voice_lead(chords).map(&:to_midi))
        .to eq([[60, 64, 67], [60, 64, 69], [62, 66, 69], [62, 67, 71]])
    end

    it 'leaves an empty progression empty' do
      expect(described_class.voice_lead([])).to be_empty
    end
  end
end
