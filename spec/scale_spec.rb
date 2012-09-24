require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Musicalism::Scale do
  describe "#notes" do

  end
  it "should the proper notes in the scale" do
    Musicalism::MajorScale.new('C').notes.should == ['C', 'D', 'E', 'F', 'G', 'A', 'B'].map { |n| Musicalism::Note.new n }
  end

  describe "#alterations" do
    it "should return an array with the altered note for the scale" do
      Musicalism::MajorScale.new('D')
    end
  end
  
  describe "Chords" do

    describe "#tonic_chord" do
      it "should return a well formed chord" do
        Musicalism::MajorScale.new('D').tonic_chord.should == ['D', '#F', 'A'].map { |n| Musicalism::Note.new n }
      end
    end
    
    describe "#supertonic_chord" do
      it "should return a well formed chord" do
        s = Musicalism::MajorScale.new('bD')
        s.supertonic_chord.should == ['bE', 'bG', 'bB'].map { |n| Musicalism::Note.new n }
      end
    end

    describe "#mediant" do
      it "should return a well formed chord" do
        s = Musicalism::MajorScale.new('B')
        s.mediant_chord.should == ['#D', '#F', '#A'].map { |n| Musicalism::Note.new n }
      end
    end

    describe "#subdominante" do
      it "should return a well formed chord" do
        s = Musicalism::MajorScale.new('#E')
        s.subdominante_chord.should == ['#A', '##C', '#E'].map { |n| Musicalism::Note.new n }
      end
    end

    describe "#dominante" do
      it "should return a well formed chord" do
        s = Musicalism::MajorScale.new('#B')
        s.dominante_chord.should == ['##F', '##A', '##C'].map { |n| Musicalism::Note.new n }
      end
    end

    describe "#submediant" do
      it "should return a well formed chord" do
        s = Musicalism::MajorScale.new('bF')
        s.submediant_chord.should == ['bD', 'bF', 'bA'].map { |n| Musicalism::Note.new n }
      end
    end

    describe "#subtonic" do
      it "should return a well formed chord" do
        s = Musicalism::MajorScale.new('#D')
        s.subtonic_chord.should == ['##C', '#E', '#G'].map { |n| Musicalism::Note.new n }
      end
    end

  end
end
