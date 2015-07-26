require 'rails_helper'

RSpec.describe Submission do
  subject { FactoryGirl.build(:submission) }

  describe 'relations' do
    it { is_expected.to belong_to :exercise }
    it { is_expected.to belong_to :submitter }
    it { is_expected.to belong_to :student_group }
    it { is_expected.to have_one :submission_evaluation }
    it { is_expected.to have_many(:exercise_registrations) }
    it { is_expected.to have_many(:term_registrations).through(:exercise_registrations) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:exercise) }
    it { is_expected.to validate_presence_of(:submitter) }
    it { is_expected.to validate_presence_of(:submitted_at) }

    it 'validates the size of all submission_assets combined is below the maximum allowed size by the exercise'
  end

  describe 'scoping' do
    describe '#for_term' do
      pending
    end

    describe '#for_exercise' do
      pending
    end

    describe '#for_tutorial_group' do
      pending
    end

    describe '#for_student_group' do
      pending
    end

    describe '#for_account' do
      pending
    end

    describe '#unmatched' do
      pending
    end

    describe '#with_evaluation' do
      pending
    end

    describe '#ordered_by_student_group' do
      pending
    end

    describe '#ordered_by_exercises' do
      pending
    end

    describe '#next' do
      pending
    end

    describe '#previous' do
      pending
    end
  end

  describe 'callbacks' do
    describe '#create_submission_evaluation after create' do
      pending
    end
  end

  describe 'evaluated?' do
    pending
  end

  describe 'result_published?' do
    pending
  end

  describe 'visible_for_student?' do
    pending
  end

  describe 'submission_assets_changed?' do
    pending
  end
end
