require 'rails_helper'
require 'models/behaviours/evaluation_behaviour'

RSpec.describe Evaluations::FixedEvaluation do
  it_behaves_like 'an evaluation'

  describe '#points' do
    let(:points_rating) { FactoryGirl.build(:fixed_points_deduction_rating, value: -42) }
    let(:percentage_rating) { FactoryGirl.build(:fixed_percentage_deduction_rating) }

    it 'returns 0 if value is 0 and rating is a points rating' do
      subject.rating = points_rating
      subject.value = 0

      expect(subject.points).to eq(0)
    end

    it 'returns rating value if value is 1 and rating is a points rating' do
      subject.rating = points_rating
      subject.value = 1

      expect(subject.points).to eq(-42)
    end

    it 'returns 0 if no rating is a percentage rating' do
      subject.rating = percentage_rating
      expect(subject.points).to eq(0)
    end

    it 'returns 0 if no rating is set' do
      subject.rating = nil
      expect(subject.points).to eq(0)
    end
  end

  describe '#percent' do
    let(:points_rating) { FactoryGirl.build(:fixed_points_deduction_rating) }
    let(:percentage_rating) { FactoryGirl.build(:fixed_percentage_deduction_rating, value: -42) }

    it 'returns 1 if value is 0 and rating is a points rating' do
      subject.rating = percentage_rating
      subject.value = 0

      expect(subject.percent).to eq(1)
    end

    it 'returns rating value if value is 1 and rating is a points rating' do
      subject.rating = percentage_rating
      subject.value = 1

      expect(subject.percent.round(2)).to eq(0.58)
    end

    it 'returns 1 if no rating is a percentage rating' do
      subject.rating = points_rating
      expect(subject.percent).to eq(1)
    end

    it 'returns 1 if no rating is set' do
      subject.rating = nil
      expect(subject.percent).to eq(1)
    end
  end
end
