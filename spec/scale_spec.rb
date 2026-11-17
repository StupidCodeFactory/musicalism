require 'spec_helper'

RSpec.describe Musicalism::Scale do
  def notes_of(names)
    names.split.map { |name| Musicalism::Note.new(name) }
  end

  def chord_of(names)
    Musicalism::Chord.new(notes_of(names))
  end

  describe '#notes' do
    {
      [Musicalism::MajorScale, 'C'] => 'C4 D4 E4 F4 G4 A4 B4',
      [Musicalism::MajorScale, 'G'] => 'G4 A4 B4 C5 D5 E5 F#5',
      [Musicalism::MajorScale, 'Cb'] => 'Cb4 Db4 Eb4 Fb4 Gb4 Ab4 Bb4',
      [Musicalism::MajorScale, 'C#3'] => 'C#3 D#3 E#3 F#3 G#3 A#3 B#3',
      [Musicalism::MinorScale, 'A'] => 'A4 B4 C5 D5 E5 F5 G5',
      [Musicalism::HarmonicMinorScale, 'A'] => 'A4 B4 C5 D5 E5 F5 G#5',
      [Musicalism::HarmonicMinorScale, 'G#'] => 'G#4 A#4 B4 C#5 D#5 E5 F##5',
      [Musicalism::MelodicMinorScale, 'A'] => 'A4 B4 C5 D5 E5 F#5 G#5',
      [Musicalism::MelodicMinorScale, 'Eb'] => 'Eb4 F4 Gb4 Ab4 Bb4 C5 D5'
    }.each do |(scale_class, root), expected|
      it "spells #{scale_class.name.split('::').last} on #{root} as #{expected}" do
        expect(scale_class.new(root).notes.map { |note| "#{note.pitch}#{note.octave}" }.join(' ')).to eq(expected)
      end
    end

    it 'rises in pitch from the root' do
      expect(Musicalism::MajorScale.new('G').notes.each_cons(2)).to all(satisfy { |low, high| low < high })
    end
  end

  describe '#alterations' do
    {
      [Musicalism::MajorScale, 'C'] => [],
      [Musicalism::MajorScale, 'G'] => %w[F#],
      [Musicalism::MajorScale, 'F'] => %w[Bb],
      [Musicalism::MajorScale, 'Eb'] => %w[Bb Eb Ab],
      [Musicalism::MajorScale, 'C#'] => %w[F# C# G# D# A# E# B#],
      [Musicalism::MajorScale, 'Cb'] => %w[Bb Eb Ab Db Gb Cb Fb],
      [Musicalism::MajorScale, 'E#'] => %w[F## C## G## D## A# E# B#],
      [Musicalism::MinorScale, 'A'] => [],
      [Musicalism::MinorScale, 'D'] => %w[Bb],
      [Musicalism::HarmonicMinorScale, 'A'] => %w[G#],
      [Musicalism::HarmonicMinorScale, 'D'] => %w[Bb C#]
    }.each do |(scale_class, root), expected|
      it "is #{expected.inspect} for #{scale_class.name.split('::').last} on #{root}" do
        expect(scale_class.new(root).alterations).to eq(expected)
      end
    end
  end

  describe 'degree chords' do
    [
      [Musicalism::MajorScale, 'D', :tonic, ['D4 F#4 A4', 'F#4 A4 D5', 'A4 D5 F#5']],
      [Musicalism::MajorScale, 'Db', :supertonic, ['Eb4 Gb4 Bb4', 'Gb4 Bb4 Eb5', 'Bb4 Eb5 Gb5']],
      [Musicalism::MajorScale, 'B', :mediant, ['D#5 F#5 A#5', 'F#5 A#5 D#6', 'A#5 D#6 F#6']],
      [Musicalism::MajorScale, 'E#', :subdominant, ['A#4 C##5 E#5', 'C##5 E#5 A#5', 'E#5 A#5 C##6']],
      [Musicalism::MajorScale, 'B#', :dominant, ['F##5 A##5 C##6', 'A##5 C##6 F##6', 'C##6 F##6 A##6']],
      [Musicalism::MajorScale, 'Fb', :submediant, ['Db5 Fb5 Ab5', 'Fb5 Ab5 Db6', 'Ab5 Db6 Fb6']],
      [Musicalism::MajorScale, 'D#', :subtonic, ['C##5 E#5 G#5', 'E#5 G#5 C##6', 'G#5 C##6 E#6']],
      [Musicalism::MinorScale, 'C', :tonic, ['C4 Eb4 G4', 'Eb4 G4 C5', 'G4 C5 Eb5']],
      [Musicalism::MinorScale, 'Bb', :supertonic, ['C5 Eb5 Gb5', 'Eb5 Gb5 C6', 'Gb5 C6 Eb6']],
      [Musicalism::MinorScale, 'B#', :mediant, ['D#5 F##5 A#5', 'F##5 A#5 D#6', 'A#5 D#6 F##6']],
      [Musicalism::MinorScale, 'E#', :subdominant, ['A#4 C#5 E#5', 'C#5 E#5 A#5', 'E#5 A#5 C#6']],
      [Musicalism::MinorScale, 'B', :dominant, ['F#5 A5 C#6', 'A5 C#6 F#6', 'C#6 F#6 A6']],
      [Musicalism::MinorScale, 'Db', :submediant, ['Bbb4 Db5 Fb5', 'Db5 Fb5 Bbb5', 'Fb5 Bbb5 Db6']],
      [Musicalism::MinorScale, 'D', :subtonic, ['C5 E5 G5', 'E5 G5 C6', 'G5 C6 E6']],
      [Musicalism::HarmonicMinorScale, 'A', :dominant, ['E5 G#5 B5', 'G#5 B5 E6', 'B5 E6 G#6']]
    ].each do |scale_class, root, degree, voicings|
      describe "#{scale_class.name.split('::').last} on #{root} #{degree} chord" do
        let(:scale) { scale_class.new(root) }

        voicings.each_with_index do |voicing, inversion|
          it "is #{voicing} in inversion #{inversion}" do
            expect(scale.degree_chord(degree, inversion: inversion)).to eq(chord_of(voicing))
          end
        end
      end
    end

    it 'honours a new inversion on a scale already asked for that chord' do
      scale = Musicalism::MajorScale.new('C')
      scale.degree_chord(:tonic)

      expect(scale.degree_chord(:tonic, inversion: 1)).to eq(chord_of('E4 G4 C5'))
    end
  end
end
