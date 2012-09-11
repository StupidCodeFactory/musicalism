require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Musicalism::Scale do
  describe "#notes" do
    
  end
  it "should the proper notes in the scale" do
    Musicalism::MajorScale.new('C').notes.should == ['C', 'D', 'E', 'F', 'G', 'A', 'B'].map { |n| Musicalism::Note.new n }
  end
end