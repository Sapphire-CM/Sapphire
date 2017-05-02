require "rails_helper"

RSpec.describe Ratings::VariableBonusPointsRating do

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:min_value).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:min_value) }
    it { is_expected.to validate_numericality_of(:max_value).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:max_value) }
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