require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Musicalism::Note do
  it "should raise an exception if the note does not exists" do
    expect {
      Musicalism::Note.new 'H'
    }.to raise_exception Musicalism::Note::UnkownNoteError, 'H is not a note'
  end

   Musicalism::Note::NOTES.flatten.each do |note|
    it "should be able to instanciate #{note}" do
      expect {
        Musicalism::Note.new note
      }.to_not raise_exception Musicalism::Note::UnkownNoteError, "#{note} is not a note"
    end
  end

  describe "comparable" do
    it "should be able to compare note based on the pitch, true case" do
      Musicalism::Note.new('A').should == Musicalism::Note.new('A')
    end

    it "should be able to compare note based on the pitch, false case" do
      Musicalism::Note.new('A').should_not == Musicalism::Note.new('D')
    end
  end

  describe "#interval_from" do
    describe "return the interval to a given note " do
      it "going up the scale" do
        Musicalism::Note.new('C').interval_from(Musicalism::Note.new('G')).should == 7
      end

      it "going down the scale" do
        Musicalism::Note.new('B').interval_from(Musicalism::Note.new('B#')).should == 1
      end

      it "also with enharmonics" do
        Musicalism::Note.new('C').interval_from(Musicalism::Note.new('B#')).should == 0
      end
    end
  end

  describe "#transpose" do
    it "should be able to transpose a note to a given interval" do
      note = Musicalism::Note.new 'A'
      note.transpose(Musicalism::Interval.new.perfect_forth).should == [Musicalism::Note.new('C##'), Musicalism::Note.new('D'), Musicalism::Note.new('Ebb')]
    end

    it "should be able to transpose a note even with the special B/C and E/F interval" do
      note = Musicalism::Note.new 'C'
      note.transpose(Musicalism::Interval.new.major_sixth).should == [Musicalism::Note.new('G##'), Musicalism::Note.new('A'), Musicalism::Note.new('Bbb')]
    end

    it "transpose even with double bb" do
      note = Musicalism::Note.new 'Cbb'
      note.transpose(Musicalism::Interval.new.minor_second).should == [Musicalism::Note.new('A##'), Musicalism::Note.new('B'), Musicalism::Note.new('Cb')]
    end

    it "transpose even with double ##" do
      note = Musicalism::Note.new 'E##'
      note.transpose(Musicalism::Interval.new.augmented_forth).should == [Musicalism::Note.new('B#'), Musicalism::Note.new('C'), Musicalism::Note.new('Dbb')]
    end

  end

  describe '#to_midi' do
    subject(:note) { Musicalism::Note.new 'E##', 3 }

    its(:to_midi) { should eq(30)}
  end
end
