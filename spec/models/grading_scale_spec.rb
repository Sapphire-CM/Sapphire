require 'rails_helper'

RSpec.describe GradingScale do
  describe 'db columns' do
    it { is_expected.to have_db_column(:grade).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:not_graded).of_type(:boolean).with_options(default: false, null: false) }
    it { is_expected.to have_db_column(:positive).of_type(:boolean).with_options(default: true, null: false) }
    it { is_expected.to have_db_column(:min_points).of_type(:integer).with_options(default: 0, null: false) }
    it { is_expected.to have_db_column(:max_points).of_type(:integer).with_options(default: 0, null: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:term) }
  end

  describe 'validations' do
    subject { FactoryBot.create(:grading_scale) }

    it { is_expected.to validate_presence_of(:grade) }
    it { is_expected.to validate_uniqueness_of(:grade).scoped_to(:term_id).case_insensitive }

    pending "min_points uniqueness"
    pending "max_points uniqueness"
    pending "points range"
  end

  describe 'scopes' do
    pending ".ordered"
    pending ".positives"
    pending ".negative"
    pending ".not_graded"
    pending ".for_grade"
    pending ".grades"
  end
end