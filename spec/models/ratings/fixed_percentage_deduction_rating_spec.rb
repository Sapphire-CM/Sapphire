require "rails_helper"

RSpec.describe Ratings::FixedPercentageDeductionRating do

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:value).is_less_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:value) }
  end

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
end