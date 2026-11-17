require 'spec_helper'

RSpec.describe Musicalism::Chord do
  def chord_of(names)
    described_class.new(names.split.map { |name| Musicalism::Note.new(name) })
  end

  describe '#quality, #root and #to_s' do
    {
      'D4 F#4 A4' => ['D', :major, 'D major'],
      'F#4 A4 D5' => ['D', :major, 'D major'],
      'A4 C5 E5' => ['A', :minor, 'A minor'],
      'B4 D5 F5' => ['B', :diminished, 'B diminished'],
      'C4 E4 G#4' => ['C', :augmented, 'C augmented']
    }.each do |names, (root, quality, name)|
      it "names #{names} #{name}" do
        expect(chord_of(names)).to have_attributes(root: have_attributes(pitch: root), quality: quality, to_s: name)
      end
    end

    it 'lists the pitches of a chord that is not a triad' do
      expect(chord_of('C4 D4 E4')).to have_attributes(quality: nil, root: nil, to_s: 'C D E')
    end
  end
end
