require 'rails_helper'

RSpec.describe RatingGroup do
  describe 'db columns' do
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:points).of_type(:integer) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:global).of_type(:boolean).with_options(null: false, default: false) }
    it { is_expected.to have_db_column(:min_points).of_type(:integer) }
    it { is_expected.to have_db_column(:max_points).of_type(:integer) }
    it { is_expected.to have_db_column(:enable_range_points).of_type(:boolean) }
    it { is_expected.to have_db_column(:row_order).of_type(:integer) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

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