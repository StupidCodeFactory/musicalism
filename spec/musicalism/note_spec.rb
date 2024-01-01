require 'spec_helper'

RSpec.describe Musicalism::Note do
  it 'should raise an exception if the note does not exists' do
    expect do
      described_class.new 'H'
    end.to raise_error described_class::UnkownNoteError, 'H is not a valid note'
  end

  describe '#initialize' do
    context 'when no octave given' do
      let(:note) { described_class.new(pitch) }

      described_class::NOTES.flatten.each do |p|
        let(:pitch) { p }

        it "should be able to instanciate #{p}" do
          expect(note.pitch).to eq(pitch)
          expect(note.octave).to eq(3)
        end
      end
    end

    context 'when given an octave' do
      let(:note) {}
    end
  end

  describe 'comparable' do
    described_class
    it 'should be able to compare note based on the pitch, true case' do
      expect(described_class.new('A')).to eq(described_class.new('A'))
    end

    it 'should be able to compare note based on the pitch, false case' do
      expect(described_class.new('A')).not_to eq(described_class.new('A'))
    end
  end

  describe '#interval_from' do
    describe 'return the interval to a given note ' do
      it 'going up the scale' do
        expect(described_class.new('C').interval_from(described_class.new('G'))).to eq(7)
        x
      end

      it 'going down the scale' do
        expect(described_class.new('B').interval_from(described_class.new('B#'))).to eq(1)
      end

      it 'also with enharmonics' do
        expect(described_class.new('C').interval_from(described_class.new('B#'))).to eq(0)
      end
    end
  end

  describe '#transpose' do
    it 'should be able to transpose a note to a given interval' do
      note = described_class.new 'A'
      expect(note.transpose(Musicalism::Interval.new.perfect_forth)).to([described_class.new('C##'),
                                                                         described_class.new('D'), described_class.new('Ebb')])
    end

    it 'should be able to transpose a note even with the special B/C and E/F interval' do
      note = described_class.new 'C'
      expect(note.transpose(Musicalism::Interval.new.major_sixth)).to eq([described_class.new('G##'),
                                                                          described_class.new('A'), described_class.new('Bbb')])
    end

    it 'transpose even with double bb' do
      note = described_class.new 'Cbb'
      expect(note.transpose(Musicalism::Interval.new.minor_second))
        .to eq([described_class.new('A##'), described_class.new('B'), described_class.new('Cb')])
    end

    it 'transpose even with double ##' do
      note = described_class.new 'E##'
      expect(note.transpose(Musicalism::Interval.new.augmented_forth))
        .to eq([described_class.new('B#'), described_class.new('C'), described_class.new('Dbb')])
    end
  end

  describe '#to_midi' do
    subject(:note) { described_class.new 'E##', 3 }

    its(:to_midi) { should eq(30) }
  end
end
