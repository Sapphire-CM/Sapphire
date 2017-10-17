require "rails_helper"
require 'models/behaviours/rating_behaviour'

RSpec.describe Ratings::PerItemPointsRating do
  it_behaves_like 'a rating'

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:min_value).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:max_value).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:multiplication_factor).is_greater_than_or_equal_to(0) }
  end

  describe '#points_value?' do
    it 'returns true' do
      expect(subject.points_value?).to be_truthy
    end
  end

  describe '#percentage_value?' do
    it 'returns false' do
      expect(subject.percentage_value?).to be_falsey
    end
  end

end