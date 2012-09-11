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
  describe "#transpose" do
    it "should be able to transpose a note to a given interval" do
      note = Musicalism::Note.new 'A'
      note.transpose(Musicalism::Interval.new.perfect_forth).should == [Musicalism::Note.new('##C'), Musicalism::Note.new('D'), Musicalism::Note.new('bbE')]
    end
    
    it "should be able to transpose a note even with the special B/C and E/F interval" do
      note = Musicalism::Note.new 'C'
      note.transpose(Musicalism::Interval.new.major_sixth).should == [Musicalism::Note.new('##G'), Musicalism::Note.new('A'), Musicalism::Note.new('bbB')]
    end

    it "transpose even with double bb" do
      note = Musicalism::Note.new 'bbC'
      note.transpose(Musicalism::Interval.new.minor_second).should == [Musicalism::Note.new('##A'), Musicalism::Note.new('B'), Musicalism::Note.new('bC')]
    end

    it "transpose even with double ##" do
      note = Musicalism::Note.new '##E'
      note.transpose(Musicalism::Interval.new.augmented_forth).should == [Musicalism::Note.new('#B'), Musicalism::Note.new('C'), Musicalism::Note.new('bbD')]
    end
    
  end
end