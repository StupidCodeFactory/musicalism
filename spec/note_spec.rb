require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Musicalism::Note do
  it "should raise an exception if the note does not exists" do
    expect {
      Musicalism::Note.new 'H'
    }.to raise_exception Musicalism::Note::UnkownNoteError, 'H is not a note'
  end
  
   Musicalism::Note::NOTES.each do |note|
    it "should be able to instanciate #{note}" do
      expect {
        Musicalism::Note.new note
      }.to_not raise_exception Musicalism::Note::UnkownNoteError, "#{note} is not a note"
    end
  end

  describe "#transpose" do
    it "should be able to transpose a note to a given interval" do
      note = Musicalism::Note.new 'A'
      note.transpose(Musicalism::Interval.new.perfect_forth).should == ['D']
    end
    
    it "should be able to transpose a note even with the special B/C and E/F interval" do
      note = Musicalism::Note.new 'C'
      note.transpose(Musicalism::Interval.new.major_sixth).should == ['A']
    end
  end
end