require 'rails_helper'

RSpec.describe Evaluation do
  describe 'db columns' do
    it { is_expected.to have_db_column(:checked).of_type(:boolean) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:type).of_type(:string) }
    it { is_expected.to have_db_column(:value).of_type(:integer) }
    it { is_expected.to have_db_column(:checked_automatically).of_type(:boolean).with_options(default: false) }
    it { is_expected.to have_db_column(:needs_review).of_type(:boolean).with_options(default: false) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:rating) }
    it { is_expected.to belong_to(:evaluation_group) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:rating) }
    it { is_expected.to validate_presence_of(:evaluation_group) }
  end

  describe 'scoping' do
    pending '.ranked'
    pending '.for_submission'
    pending '.for_exercise'
    pending '.automatically_checked'
  end

  describe 'methods' do
    pending '.create_for_evaluation_group'
    pending '.create_for_rating'
    pending '#update_result!'

    describe '#points' do
      it 'is expected to return 0' do
        expect(subject.points).to eq(0)
      end
    end

    describe '#percent' do
      it 'is expected to return 0' do
        expect(subject.percent).to eq(1)
      end
    end
  end
end