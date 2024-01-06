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
          expect(note.octave).to eq(4)
        end
      end
    end

    context 'when given an octave' do
      context 'with lowest notes' do
        let(:note) { described_class.new(pitch) }

        context 'with A0' do
          let(:pitch) { 'A0' }

          it 'parses correctly' do
            expect(note.pitch).to eq('A')
            expect(note.octave).to eq(0)
          end
        end

        context 'with B0' do
          let(:pitch) { 'B0' }

          it 'parses correctly' do
            expect(note.pitch).to eq('B')
            expect(note.octave).to eq(0)
          end
        end

        context 'with sharps' do
          context 'with A##0' do
            let(:pitch) { 'A##0' }

            it 'parses correctly' do
              expect(note.pitch).to eq('A##')
              expect(note.octave).to eq(0)
            end
          end

          context 'with B#0' do
            let(:pitch) { 'B#0' }

            it 'parses correctly' do
              expect(note.pitch).to eq('B#')
              expect(note.octave).to eq(0)
            end
          end
        end

        context 'with flats' do
          let(:pitch) { 'Bbb0' }

          it 'parses correctly' do
            expect(note.pitch).to eq('Bbb')
            expect(note.octave).to eq(0)
          end

          context 'when given a Ab0' do
            let(:pitch) { 'Ab0' }

            it 'raises an error' do
              expect { note }.to raise_error(described_class::UnkownNoteError, "#{pitch} is not a valid note")
            end
          end
        end

        context 'when given a note lower than the lowest bound A0' do
          context 'with not lower than A' do
            let(:pitch) { 'G0' }

            it 'raises an error' do
              expect { note }.to raise_error(described_class::UnkownNoteError, "#{pitch} is not a valid note")
            end
          end
        end
      end

      context 'when given a note between C1 and B7' do
        let(:pitch) { ('A'..'G').to_a.sample }
        let(:octave) { (1..7).to_a.sample }
        let(:note) { described_class.new([pitch, octave].join) }

        it 'parses correctly' do
          expect(note.pitch).to eq(pitch)
          expect(note.octave).to eq(octave)
        end

        context 'when given sharps' do
          let(:note) { described_class.new('b##2') }

          it 'parses correctly' do
            expect(note.pitch).to eq('B##')
            expect(note.octave).to eq(2)
          end

          context 'when give a note between in 7th octave' do
            context 'when given a double sharp modifier' do
              context 'when given a not between C to A' do
                let(:pitch) { (('C'..'G').to_a + ['A']).sample }
                let(:note) { described_class.new("#{pitch}##7") }

                it 'parses correctly' do
                  expect(note.pitch).to eq("#{pitch}##")
                  expect(note.octave).to eq(7)
                end
              end

              context 'when out of higher bound B##7' do
                let(:note) { described_class.new('b##7') }

                it 'raises an error' do
                  expect { note }.to raise_error(described_class::UnkownNoteError, 'b##7 is not a valid note')
                end
              end
            end

            context 'when given B#7' do
              let(:note) { described_class.new('b#7') }

              it 'parses correctly' do
                expect(note.pitch).to eq('B#')
                expect(note.octave).to eq(7)
              end
            end
          end
        end
      end

      context 'when given C8, the highest midi note' do
        let(:note) { described_class.new('c8') }

        it 'parses correctly' do
          expect(note.pitch).to eq('C')
          expect(note.octave).to eq(8)
        end

        context 'when given with flats' do
          let(:flats) { %w[b bb].sample }
          let(:note) { described_class.new("c#{flats}8") }

          it 'parses correctly' do
            expect(note.pitch).to eq("C#{flats}")
            expect(note.octave).to eq(8)
          end
        end

        context 'when given a note above C8, the highest midi note' do
          let(:pitch) { 'c#8' }
          let(:note) { described_class.new(pitch) }

          it 'raises an error' do
            expect { note }.to raise_error(described_class::UnkownNoteError, 'c#8 is not a valid note')
          end
        end
      end
    end
  end

  describe 'comparable' do
    it 'should be able to compare note based on the pitch, true case' do
      expect(described_class.new('A')).to eq(described_class.new('A'))
    end

    it 'should be able to compare note based on the pitch, false case' do
      expect(described_class.new('A')).not_to eq(described_class.new('A3'))
    end
  end

  describe '#interval_from' do
    describe 'return the interval to a given note ' do
      it 'going up the scale' do
        expect(described_class.new('C').interval_from(described_class.new('G'))).to eq(7)
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
      expect(note.transpose(Musicalism::Interval.new.perfect_forth)).to eq([described_class.new('C##'),
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
    subject(:note) { described_class.new 'E##3' }

    its(:to_midi) { should eq(52) }
  end

  describe '#next' do
    subject { described_class.new(note) }

    context 'when B or E' do
      context 'with no alteration' do
        let(:note) { 'B0' }

        it 'has the correct next note' do
          expect(subject.next).to eq(described_class.new('C1'))
        end
      end
    end

    context 'when not B or E' do
      context 'with no alterations' do
        let(:note) { 'C1' }

        it { expect(subject.next).to eq(described_class.new('C#1')) }
      end

      context 'with a sharp' do
        let(:note) { 'F#4' }

        it { expect(subject.next).to eq(described_class.new('G4')) }
      end

      context 'with a flat' do
        let(:note) { 'Db4' }

        it { expect(subject.next).to eq(described_class.new('D4')) }
      end
    end

    context 'when changing octave' do
      let(:note) { described_class.new('B0') }

      it 'has the correct next note' do
        expect(note.next).to eq(described_class.new('C1'))
      end
    end

    context 'when using sharps' do
      let(:note) { described_class.new('A#0') }

      it 'has the correct next note' do
        expect(note.next).to eq(described_class.new('B#0'))
      end

      context 'when next note needs an alteration' do
        context 'with single sharp' do
          let(:note) { described_class.new('C1') }

          it 'has the correct next note' do
            expect(note.next).to eq(described_class.new('C#1'))
          end
        end

        context 'with double sharps' do
          let(:note) { described_class.new('E#') }

          it 'has the correct next note' do
            expect(note.next).to eq(described_class.new('F#'))
            expect(note.next.next).to eq(described_class.new('G'))
          end
        end
      end

      context 'when next not would require using double #' do
        let(:note) { described_class.new('B#0') }

        it 'has the correct next note' do
          expect(note.next).to eq(described_class.new('C#1'))
        end
      end

      context 'when using double flats' do
        let(:note) { described_class.new('Bbb0') }

        it 'has the correct next note' do
          expect(note.next).to eq(described_class.new('Cbb1'))
        end
      end
    end
  end

  describe '.parse_note_and_alteration' do
    specify do
      expect(described_class.parse_note_and_alteration('A0'))
        .to eq({ pitch: 'A', alteration: nil, octave: 0 })
    end

    specify do
      expect(described_class.parse_note_and_alteration('B0'))
        .to eq({ pitch: 'B', alteration: nil, octave: 0 })
    end

    specify do
      expect(described_class.parse_note_and_alteration('Bb0'))
        .to eq({ pitch: 'Bb', alteration: 'b', octave: 0 })
    end

    specify do
      expect(described_class.parse_note_and_alteration('Bbb0'))
        .to eq({ pitch: 'Bbb', alteration: 'bb', octave: 0 })
    end

    specify do
      expect(described_class.parse_note_and_alteration('B#0'))
        .to eq({ pitch: 'B#', alteration: '#', octave: 0 })
    end

    specify do
      expect(described_class.parse_note_and_alteration('B##0'))
        .to eq({ pitch: 'B##', alteration: '##', octave: 0 })
    end

    specify do
      expect(described_class.parse_note_and_alteration('Cb3'))
        .to eq({ pitch: 'Cb', alteration: 'b', octave: 3 })
    end

    specify do
      expect(described_class.parse_note_and_alteration('C'))
        .to eq(pitch: 'C', alteration: nil, octave: described_class::DEFAULT_CENTER_OCTAVE)
    end

    specify do
      expect(described_class.parse_note_and_alteration('Fbb6'))
        .to eq(pitch: 'Fbb', alteration: 'bb', octave: 6)
    end

    specify do
      expect(described_class.parse_note_and_alteration('A##7'))
        .to eq(pitch: 'A##', alteration: '##', octave: 7)
    end

    specify do
      expect(described_class.parse_note_and_alteration('B#7'))
        .to eq(pitch: 'B#', alteration: '#', octave: 7)
    end

    specify do
      expect(described_class.parse_note_and_alteration('Bbb7'))
        .to eq(pitch: 'Bbb', alteration: 'bb', octave: 7)
    end

    specify do
      expect(described_class.parse_note_and_alteration('Cb8'))
        .to eq(pitch: 'Cb', alteration: 'b', octave: 8)
    end

    specify do
      expect(described_class.parse_note_and_alteration('Cbb8'))
        .to eq(pitch: 'Cbb', alteration: 'bb', octave: 8)
    end
  end
end
