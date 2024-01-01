require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Musicalism::Scale do
  describe '#notes' do
  end
  it 'should the proper notes in the scale' do
    Musicalism::MajorScale.new('C').notes.should == %w[C D E F G A B].map do |n|
                                                      Musicalism::Note.new n
                                                    end
  end

  describe '#alterations' do
    it 'should return an array with the altered note for the scale' do
      Musicalism::MajorScale.new('D')
    end
  end

  describe 'Chords' do
    describe 'Major' do
      describe '#tonic_chord' do
        let(:scale) { Musicalism::MajorScale.new('D') }
        it 'should return a well formed chord' do
          scale.tonic_chord.should == Musicalism::Chord.new(['D', 'F#', 'A'].map { |n| Musicalism::Note.new n })
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.tonic_chord(inversion: 1).should == Musicalism::Chord.new(['F#', 'A', 'D'].map do |n|
                                                                              Musicalism::Note.new n
                                                                            end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.tonic_chord(inversion: 2).should == Musicalism::Chord.new(['A', 'D', 'F#'].map do |n|
                                                                              Musicalism::Note.new n
                                                                            end)
          end
        end
      end

      describe '#supertonic_chord' do
        let(:scale) { Musicalism::MajorScale.new('Db') }
        it 'should return a well formed chord' do
          scale.supertonic_chord.should == Musicalism::Chord.new(%w[Eb Gb Bb].map { |n| Musicalism::Note.new n })
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.supertonic_chord(inversion: 1).should == Musicalism::Chord.new(%w[Gb Bb Eb].map do |n|
                                                                                   Musicalism::Note.new n
                                                                                 end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.supertonic_chord(inversion: 2).should == Musicalism::Chord.new(%w[Bb Eb Gb].map do |n|
                                                                                   Musicalism::Note.new n
                                                                                 end)
          end
        end
      end

      describe '#mediant' do
        let(:scale) { Musicalism::MajorScale.new('B') }
        it 'should return a well formed chord' do
          scale.mediant_chord.should == Musicalism::Chord.new(['D#', 'F#', 'A#'].map { |n| Musicalism::Note.new n })
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.mediant_chord(inversion: 1).should == Musicalism::Chord.new(['F#', 'A#', 'D#'].map do |n|
                                                                                Musicalism::Note.new n
                                                                              end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.mediant_chord(inversion: 2).should == Musicalism::Chord.new(['A#', 'D#', 'F#'].map do |n|
                                                                                Musicalism::Note.new n
                                                                              end)
          end
        end
      end

      describe '#subdominante' do
        let(:scale) { Musicalism::MajorScale.new('E#') }
        it 'should return a well formed chord' do
          scale.subdominante_chord.should == Musicalism::Chord.new(['A#', 'C##', 'E#'].map do |n|
                                                                     Musicalism::Note.new n
                                                                   end)
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.subdominante_chord(inversion: 1).should == Musicalism::Chord.new(['C##', 'E#', 'A#'].map do |n|
                                                                                     Musicalism::Note.new n
                                                                                   end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.subdominante_chord(inversion: 2).should == Musicalism::Chord.new(['E#', 'A#', 'C##'].map do |n|
                                                                                     Musicalism::Note.new n
                                                                                   end)
          end
        end
      end

      describe '#dominante' do
        let(:scale) { Musicalism::MajorScale.new('B#') }
        it 'should return a well formed chord' do
          scale.dominante_chord.should == Musicalism::Chord.new(['F##', 'A##', 'C##'].map do |n|
                                                                  Musicalism::Note.new n
                                                                end)
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.dominante_chord(inversion: 1).should == Musicalism::Chord.new(['A##', 'C##', 'F##'].map do |n|
                                                                                  Musicalism::Note.new n
                                                                                end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.dominante_chord(inversion: 2).should == Musicalism::Chord.new(['C##', 'F##', 'A##'].map do |n|
                                                                                  Musicalism::Note.new n
                                                                                end)
          end
        end
      end

      describe '#submediant' do
        let(:scale) { Musicalism::MajorScale.new('Fb') }
        it 'should return a well formed chord' do
          scale.submediant_chord.should == Musicalism::Chord.new(%w[Db Fb Ab].map { |n| Musicalism::Note.new n })
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.submediant_chord(inversion: 1).should == Musicalism::Chord.new(%w[Fb Ab Db].map do |n|
                                                                                   Musicalism::Note.new n
                                                                                 end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.submediant_chord(inversion: 2).should == Musicalism::Chord.new(%w[Ab Db Fb].map do |n|
                                                                                   Musicalism::Note.new n
                                                                                 end)
          end
        end
      end

      describe '#subtonic' do
        let(:scale) { Musicalism::MajorScale.new('D#') }
        it 'should return a well formed chord' do
          scale.subtonic_chord.should == Musicalism::Chord.new(['C##', 'E#', 'G#'].map { |n| Musicalism::Note.new n })
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.subtonic_chord(inversion: 1).should == Musicalism::Chord.new(['E#', 'G#', 'C##'].map do |n|
                                                                                 Musicalism::Note.new n
                                                                               end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.subtonic_chord(inversion: 2).should == Musicalism::Chord.new(['G#', 'C##', 'E#'].map do |n|
                                                                                 Musicalism::Note.new n
                                                                               end)
          end
        end
      end
    end

    describe 'Minor' do
      describe '#tonic' do
        let(:scale) { Musicalism::MinorScale.new('C') }

        it 'should return a well formed chord' do
          scale.tonic_chord.should == Musicalism::Chord.new(%w[C Eb G].map { |n| Musicalism::Note.new n })
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.tonic_chord(inversion: 1).should == Musicalism::Chord.new(%w[Eb G C].map do |n|
                                                                              Musicalism::Note.new n
                                                                            end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.tonic_chord(inversion: 2).should == Musicalism::Chord.new(%w[G C Eb].map do |n|
                                                                              Musicalism::Note.new n
                                                                            end)
          end
        end
      end

      describe '#subtonic' do
        let(:scale) { Musicalism::MinorScale.new('Bb') }

        it 'should return a well formed chord' do
          scale.supertonic_chord.should == Musicalism::Chord.new(%w[C Eb Gb].map { |n| Musicalism::Note.new n })
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.supertonic_chord(inversion: 1).should == Musicalism::Chord.new(%w[Eb Gb C].map do |n|
                                                                                   Musicalism::Note.new n
                                                                                 end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.supertonic_chord(inversion: 2).should == Musicalism::Chord.new(%w[Gb C Eb].map do |n|
                                                                                   Musicalism::Note.new n
                                                                                 end)
          end
        end
      end

      describe '#mediant' do
        let(:scale) { Musicalism::MinorScale.new('B#') }

        it 'should return a well formed chord' do
          scale.mediant_chord.should == Musicalism::Chord.new(['D#', 'F##', 'A#'].map { |n| Musicalism::Note.new n })
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.mediant_chord(inversion: 1).should == Musicalism::Chord.new(['F##', 'A#', 'D#'].map do |n|
                                                                                Musicalism::Note.new n
                                                                              end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.mediant_chord(inversion: 2).should == Musicalism::Chord.new(['A#', 'D#', 'F##'].map do |n|
                                                                                Musicalism::Note.new n
                                                                              end)
          end
        end
      end

      describe '#subdominante' do
        let(:scale) { Musicalism::MinorScale.new('E#') }
        it 'should return a well formed chord' do
          scale.subdominante_chord.should == Musicalism::Chord.new(['A#', 'C#', 'E#'].map do |n|
                                                                     Musicalism::Note.new n
                                                                   end)
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.subdominante_chord(inversion: 1).should == Musicalism::Chord.new(['C#', 'E#', 'A#'].map do |n|
                                                                                     Musicalism::Note.new n
                                                                                   end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.subdominante_chord(inversion: 2).should == Musicalism::Chord.new(['E#', 'A#', 'C#'].map do |n|
                                                                                     Musicalism::Note.new n
                                                                                   end)
          end
        end
      end

      describe '#dominante' do
        let(:scale) { Musicalism::MinorScale.new('B') }
        it 'should return a well formed chord' do
          scale.dominante_chord.should == Musicalism::Chord.new(['F#', 'A', 'C#'].map { |n| Musicalism::Note.new n })
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.dominante_chord(inversion: 1).should == Musicalism::Chord.new(['A', 'C#', 'F#'].map do |n|
                                                                                  Musicalism::Note.new n
                                                                                end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.dominante_chord(inversion: 2).should == Musicalism::Chord.new(['C#', 'F#', 'A'].map do |n|
                                                                                  Musicalism::Note.new n
                                                                                end)
          end
        end
      end

      describe '#submediant' do
        let(:scale) { Musicalism::MinorScale.new('Db') }

        it 'should return a well formed chord' do
          scale.submediant_chord.should == Musicalism::Chord.new(%w[Bbb Db Fb].map { |n| Musicalism::Note.new n })
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.submediant_chord(inversion: 1).should == Musicalism::Chord.new(%w[Db Fb Bbb].map do |n|
                                                                                   Musicalism::Note.new n
                                                                                 end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.submediant_chord(inversion: 2).should == Musicalism::Chord.new(%w[Fb Bbb Db].map do |n|
                                                                                   Musicalism::Note.new n
                                                                                 end)
          end
        end
      end

      describe '#subtonic' do
        let(:scale) { Musicalism::MinorScale.new('D') }

        it 'should return a well formed chord' do
          scale.subtonic_chord.should == Musicalism::Chord.new(%w[C E G].map { |n| Musicalism::Note.new n })
        end

        describe 'with inversion' do
          it 'should return a well formed chord, inversion 1' do
            scale.subtonic_chord(inversion: 1).should == Musicalism::Chord.new(%w[E G C].map do |n|
                                                                                 Musicalism::Note.new n
                                                                               end)
          end

          it 'should return a well formed chord, inversion 2' do
            scale.subtonic_chord(inversion: 2).should == Musicalism::Chord.new(%w[G C E].map do |n|
                                                                                 Musicalism::Note.new n
                                                                               end)
          end
        end
      end
    end
  end
end
