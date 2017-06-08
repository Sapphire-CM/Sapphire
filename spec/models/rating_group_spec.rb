require 'rails_helper'

RSpec.describe RatingGroup do
  describe 'associations' do
    it { is_expected.to belong_to(:exercise).touch(true) }
    it { is_expected.to have_many(:ratings).dependent(:destroy) }
    it { is_expected.to have_many(:evaluation_groups).dependent(:destroy) }
  end

  describe 'validations' do
    subject { FactoryGirl.build(:rating_group) }

    it { is_expected.to validate_presence_of(:exercise) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title).scoped_to(:exercise_id) }

    describe 'points' do
      it 'validates points if global is false' do
        subject.global = false
        expect(subject).to validate_presence_of(:points)
      end

      it 'does not validate points if global is true' do
        subject.global = true
        expect(subject).not_to validate_presence_of(:points)
      end

      pending 'should validate that points are within min_points and max_points'
    end

    describe 'min_points and max_points' do
      pending 'should validate that min_points are less than max_points'
    end

  end

  describe 'callbacks' do
    describe '#create_evaluation_groups' do
      pending 'is called after create'
      pending 'is not called after update'
    end

    describe '#update_exercise_points' do
      pending 'is called after changing points'
      pending 'is called after changing max_points'
    end
  end
end