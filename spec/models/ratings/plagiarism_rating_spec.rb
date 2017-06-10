require "rails_helper"
require 'models/behaviours/rating_behaviour'

RSpec.describe Ratings::PlagiarismRating do
  it_behaves_like 'a rating'

  describe '#points_value?' do
    it 'returns false' do
      expect(subject.points_value?).to be_falsey
    end
  end

  describe '#percentage_value?' do
    it 'returns true' do
      expect(subject.percentage_value?).to be_truthy
    end
  end

  describe '#value' do
    it 'returns -100' do
      expect(subject.value).to eq(-100.0)
    end
  end

end