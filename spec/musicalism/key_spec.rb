require 'spec_helper'

RSpec.describe Musicalism::Key do
  def chord_of(names)
    Musicalism::Chord.new(names.split.map { |name| Musicalism::Note.new(name) })
  end

  describe '.new' do
    it 'refuses a mode other than major or minor' do
      expect { described_class.new('C', :dorian) }.to raise_error(ArgumentError, 'dorian is not a key mode, use major or minor')
    end
  end

  describe '.[]' do
    it 'reads a key from its name' do
      expect([described_class['F# minor'], described_class['Bb Major']])
        .to eq([described_class.minor('F#'), described_class.major('Bb')])
    end

    it 'refuses an unknown mode' do
      expect { described_class['C dorian'] }.to raise_error(ArgumentError, 'dorian is not a key mode, use major or minor')
    end

    it 'refuses an unknown tonic' do
      expect { described_class['H major'] }.to raise_error(Musicalism::Note::UnkownNoteError)
    end
  end

  describe '#to_s' do
    subject { described_class.major('Eb') }

    it { is_expected.to have_attributes(to_s: 'Eb major') }
  end

  describe '#==' do
    it 'ignores the octave of the tonic' do
      expect(described_class.major('C3')).to eq(described_class.major('C5'))
    end

    it 'tells major from minor' do
      expect(described_class.major('C')).not_to eq(described_class.minor('C'))
    end

    it 'tells enharmonic keys apart' do
      expect(described_class.major('Db')).not_to eq(described_class.major('C#'))
    end
  end

  describe '#relative' do
    {
      described_class.major('C') => described_class.minor('A'),
      described_class.major('G') => described_class.minor('E'),
      described_class.major('F') => described_class.minor('D'),
      described_class.major('Gb') => described_class.minor('Eb'),
      described_class.major('C#') => described_class.minor('A#'),
      described_class.minor('A') => described_class.major('C'),
      described_class.minor('D#') => described_class.major('F#'),
      described_class.minor('Ab') => described_class.major('Cb')
    }.each do |key, relative|
      it "of #{key} is #{relative}" do
        expect(key.relative).to eq(relative)
      end
    end

    it 'puts the relative minor tonic a minor third below the major tonic' do
      expect(described_class.major('C4').relative.tonic).to have_attributes(pitch: 'A', octave: 3)
    end

    it 'comes back to the same tonic octave' do
      expect(described_class.major('C4').relative.relative.tonic).to have_attributes(pitch: 'C', octave: 4)
    end
  end

  describe '#parallel' do
    it 'keeps the tonic and swaps the mode' do
      expect([described_class.major('C').parallel, described_class.minor('C').parallel])
        .to eq([described_class.minor('C'), described_class.major('C')])
    end
  end

  describe '#dominant_key and #subdominant_key' do
    {
      described_class.major('C') => [described_class.major('G'), described_class.major('F')],
      described_class.major('F#') => [described_class.major('C#'), described_class.major('B')],
      described_class.major('Gb') => [described_class.major('Db'), described_class.major('Cb')],
      described_class.minor('A') => [described_class.minor('E'), described_class.minor('D')]
    }.each do |key, (dominant, subdominant)|
      it "of #{key} are #{dominant} and #{subdominant}" do
        expect([key.dominant_key, key.subdominant_key]).to eq([dominant, subdominant])
      end
    end

    it 'keeps the tonic in the same octave so walking the circle never leaves it' do
      expect(described_class.major('G4').dominant_key.tonic).to have_attributes(pitch: 'D', octave: 4)
    end

    it 'undo each other' do
      expect(described_class.major('E').dominant_key.subdominant_key).to eq(described_class.major('E'))
    end
  end

  describe '#note' do
    let(:key) { described_class.major('C4') }

    it 'gives the note on a scale degree counted from 1' do
      expect(key.note(5)).to have_attributes(pitch: 'G', octave: 4)
    end

    it 'carries on into the next octaves past the seventh degree' do
      expect([key.note(8), key.note(16)]).to contain_exactly(
        have_attributes(pitch: 'C', octave: 5), have_attributes(pitch: 'D', octave: 6)
      )
    end

    it 'refuses a degree below 1' do
      expect { key.note(0) }.to raise_error(ArgumentError, 'degree must be 1 or more, got 0')
    end
  end

  describe '#signature' do
    {
      described_class.major('C') => [],
      described_class.minor('A') => [],
      described_class.minor('E') => %w[F#],
      described_class.major('Bb') => %w[Bb Eb],
      described_class.minor('F') => %w[Bb Eb Ab Db],
      described_class.minor('G#') => %w[F# C# G# D# A#]
    }.each do |key, signature|
      it "of #{key} is #{signature.inspect}" do
        expect(key.signature).to eq(signature)
      end
    end

    it 'is shared by relative keys' do
      keys = %w[C G D A E B F# C# F Bb Eb Ab Db Gb Cb].map { |tonic| described_class.major(tonic) }

      expect(keys).to all(satisfy { |key| key.relative.signature == key.signature })
    end
  end

  describe '#chord' do
    let(:key) { described_class.major('C') }

    it 'builds the chord on a roman numeral degree' do
      expect(key.chord(:V)).to eq(chord_of('G4 B4 D5'))
    end

    it 'reads the numeral whatever its case' do
      expect(key.chord(:ii)).to eq(key.chord(:II))
    end

    it 'gives MIDI note numbers ready to play' do
      expect(key.chord(:V).to_midi).to eq([67, 71, 74])
    end

    it 'inverts the chord' do
      expect(key.chord(:vi, inversion: 1)).to eq(chord_of('C5 E5 A5'))
    end

    it 'refuses a numeral outside I to VII' do
      expect { key.chord(:VIII) }.to raise_error(ArgumentError, 'VIII is not a roman numeral between I and VII')
    end
  end

  describe '#numerals' do
    it 'writes major chords upper case and minor or diminished chords lower case' do
      expect([described_class.major('C').numerals, described_class.minor('A').numerals])
        .to eq([%i[I ii iii IV V vi vii], %i[i ii III iv V VI vii]])
    end
  end

  describe '#pivot_chords' do
    it 'lists the chords both keys share, best pivot first' do
      expect(described_class.major('C').pivot_chords(described_class.major('G')).map(&:to_s)).to eq(
        [
          'A minor: vi in C major = ii in G major',
          'E minor: iii in C major = vi in G major',
          'C major: I in C major = IV in G major',
          'G major: V in C major = I in G major'
        ]
      )
    end

    it 'prefers a chord that is subdominant in the new key and keeps tonic chords last' do
      expect(described_class.major('C').pivot_chords('F major').map(&:to_s)).to eq(
        [
          'D minor: ii in C major = vi in F major',
          'A minor: vi in C major = iii in F major',
          'C major: I in C major = V in F major',
          'F major: IV in C major = I in F major'
        ]
      )
    end

    it 'exposes the chord and its numeral in each key' do
      pivot = described_class.major('C').pivot_chords('G major').first

      expect(pivot).to have_attributes(chord: chord_of('A4 C5 E5'), from_numeral: :vi, to_numeral: :ii)
    end

    it 'is empty when the keys share no chord' do
      expect(described_class.major('C').pivot_chords('F# major')).to be_empty
    end
  end

  describe '#modulate_to' do
    let(:c_major) { described_class.major('C') }

    def pivots_chosen_over_many_runs(destination)
      Array.new(50) { |seed| c_major.modulate_to(destination, random: Random.new(seed))[1].to_s }.uniq
    end

    it 'plays I, the pivot, then V and I of the new key' do
      expect(c_major.modulate_to('G major', via: :vi).map(&:to_s)).to eq(['C major', 'A minor', 'D major', 'G major'])
    end

    it 'varies the pivot between the chords that are tonic in neither key' do
      expect([pivots_chosen_over_many_runs('G major'), pivots_chosen_over_many_runs('A minor')])
        .to match([contain_exactly('A minor', 'E minor'), contain_exactly('D minor', 'B diminished', 'F major')])
    end

    it 'repeats the same choice for the same random seed' do
      expect(c_major.modulate_to('A minor', random: Random.new(3)))
        .to eq(c_major.modulate_to('A minor', random: Random.new(3)))
    end

    it 'skips the pivot when every shared chord is the tonic of one of the keys' do
      expect(c_major.modulate_to('F minor').map(&:to_s)).to eq(['C major', 'C major', 'F minor'])
    end

    it 'goes through the pivot given as a numeral of the key it leaves, in any case' do
      expect(c_major.modulate_to('G major', via: :III)[1].to_s).to eq('E minor')
    end

    it 'goes through a pivot taken from pivot_chords' do
      pivot = c_major.pivot_chords('G major').last

      expect(c_major.modulate_to('G major', via: pivot)[1].to_s).to eq('G major')
    end

    it 'refuses a pivot the new key does not share' do
      expect { c_major.modulate_to('G major', via: :ii) }
        .to raise_error(ArgumentError, 'ii in C major is not a chord of G major')
    end

    it 'goes straight to V and I of the new key when the keys share no chord' do
      expect(c_major.modulate_to('F# major').map(&:to_s)).to eq(['C major', 'C# major', 'F# major'])
    end

    it 'voice-leads the chords so each one moves as little as possible' do
      expect(c_major.modulate_to(described_class.major('G'), via: :vi).map(&:to_midi))
        .to eq([[60, 64, 67], [60, 64, 69], [62, 66, 69], [62, 67, 71]])
    end

    it 'keeps every chord in root position in its own key without voice leading' do
      expect(c_major.modulate_to('G major', via: :vi, voice_leading: false).map(&:to_midi))
        .to eq([[60, 64, 67], [69, 72, 76], [74, 78, 81], [67, 71, 74]])
    end
  end

  describe '#chords' do
    it 'lists the seven diatonic triads of a major key' do
      expect(described_class.major('C').chords).to eq(
        ['C4 E4 G4', 'D4 F4 A4', 'E4 G4 B4', 'F4 A4 C5', 'G4 B4 D5', 'A4 C5 E5', 'B4 D5 F5'].map { |names| chord_of(names) }
      )
    end

    {
      tonic: ['C4 E4 G4', 'A4 C5 E5', 'E4 G4 B4'],
      subdominant: ['F4 A4 C5', 'D4 F4 A4', 'A4 C5 E5'],
      dominant: ['G4 B4 D5', 'B4 D5 F5']
    }.each do |function, voicings|
      it "groups the #{function} function chords of a major key, primary chord first" do
        expect(described_class.major('C').chords(function)).to eq(voicings.map { |names| chord_of(names) })
      end
    end

    it 'groups the dominant function chords of a minor key from harmonic minor' do
      expect(described_class.minor('A').chords(:dominant)).to eq([chord_of('E5 G#5 B5'), chord_of('G#5 B5 D6')])
    end

    it 'refuses an unknown harmonic function' do
      expect { described_class.major('C').chords(:mediant) }
        .to raise_error(ArgumentError, 'mediant is not a harmonic function, use tonic, subdominant or dominant')
    end

    it 'takes the dominant and leading-tone chords of a minor key from harmonic minor' do
      expect(described_class.minor('A').chords).to eq(
        ['A4 C5 E5', 'B4 D5 F5', 'C5 E5 G5', 'D5 F5 A5', 'E5 G#5 B5', 'F5 A5 C6', 'G#5 B5 D6'].map { |names| chord_of(names) }
      )
    end
  end
end
