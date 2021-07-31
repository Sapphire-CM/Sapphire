require 'rails_helper'
require 'models/behaviours/evaluation_behaviour'

RSpec.describe Evaluations::VariableEvaluation do
  it_behaves_like 'an evaluation'

  describe 'validations' do
    describe '#value_range' do
      let(:rating) { FactoryBot.build(:variable_points_deduction_rating, min_value: -10, max_value: -3) }

      before :each do
        subject.rating = rating
      end

      it 'is valid if value is in range' do
        subject.value = -4

        subject.valid?
        expect(subject.errors).not_to have_key(:value)
      end

      it 'is not valid if value is below the range' do
        subject.value = -40

        subject.valid?
        expect(subject.errors).to have_key(:value)
      end

      it 'is not valid if value is above the range' do
        subject.value = -1

        subject.valid?
        expect(subject.errors).to have_key(:value)
      end

    end
  end

  describe 'methods' do
    describe '#points' do
      let(:points_rating) { FactoryBot.build(:variable_points_deduction_rating, min_value: -10, max_value: 0) }
      let(:percentage_rating) { FactoryBot.build(:variable_percentage_deduction_rating) }

      it 'returns the value if rating is a points rating' do
        subject.rating = points_rating
        subject.value = -10

        expect(subject.points).to eq(-10)
      end

      it 'returns 0 if rating is a percentage rating' do
        subject.rating = percentage_rating
        expect(subject.points).to eq(0)
      end

      it 'returns 0 if no rating is set' do
        subject.rating = nil
        expect(subject.points).to eq(0)
      end
    end

    describe '#percent' do
      let(:points_rating) { FactoryBot.build(:fixed_points_deduction_rating) }
      let(:percentage_rating) { FactoryBot.build(:fixed_percentage_deduction_rating, min_value: -15, max_value: 0) }

      it 'returns evaluation value if rating is a percentage rating' do
        subject.rating = percentage_rating
        subject.value = -10

        expect(subject.percent.round(2)).to eq(0.90)
      end

      it 'returns 1 if rating is a points rating' do
        subject.rating = points_rating
        expect(subject.percent).to eq(1)
      end

      it 'returns 1 if no rating is set' do
        subject.rating = nil
        expect(subject.percent).to eq(1)
      end
    end

    describe '#show_to_students?' do
      it 'returns true if value is positive' do
        subject.value = 42

        expect(subject.show_to_students?).to be_truthy
      end

      it 'returns true if value is 0' do
        subject.value = 0

        expect(subject.show_to_students?).to be_truthy
      end

      it 'returns true if value is negative' do
        subject.value = -21

        expect(subject.show_to_students?).to be_truthy
      end

      it 'returns false if value is nil' do
        subject.value = nil

        expect(subject.show_to_students?).to be_falsey
      end
    end
  end
end
