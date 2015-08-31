require 'rails_helper'

describe ExerciseRegistration do
  it { is_expected.to belong_to(:exercise) }
  it { is_expected.to belong_to(:submission) }
  it { is_expected.not_to belong_to(:student_group) }
  it { is_expected.to belong_to(:term_registration) }
  it { is_expected.to validate_presence_of(:exercise) }
  it { is_expected.to validate_presence_of(:term_registration) }
  it { is_expected.to validate_presence_of(:submission) }
  it { is_expected.to validate_numericality_of(:points).only_integer }

  describe 'scoping' do
    describe '.current' do
      let!(:current_submissions) { FactoryGirl.create_list(:submission, 3) }
      let!(:outdated_submissions) { FactoryGirl.create_list(:submission, 3, :outdated) }

      let!(:current_exercise_registrations) { current_submissions.map { |s| FactoryGirl.create(:exercise_registration, exercise: s.exercise, submission: s) } }
      let!(:outdated_exercise_registrations) { outdated_submissions.map { |s| FactoryGirl.create(:exercise_registration, exercise: s.exercise, submission: s) } }

      it 'returns exercise registrations only for current submissions' do
        expect(described_class.current).to match_array(current_exercise_registrations)
      end
    end
  end

  context 'uniqueness validation' do
    context 'for solitary submission' do
      it 'is uniqu' do
        term = FactoryGirl.create :term
        exercise = FactoryGirl.create :exercise, term: term
        tutorial_group = FactoryGirl.create :tutorial_group, term: term
        account = FactoryGirl.create :account
        term_registration = FactoryGirl.create :term_registration, :student, account: account
        submission = FactoryGirl.create :submission, exercise: exercise, submitter: account

        ExerciseRegistration.create! exercise: exercise, term_registration: term_registration, submission: submission
        subject = ExerciseRegistration.new exercise: exercise, term_registration: term_registration, submission: submission
        expect(subject.save).to eq(false)
      end
    end

    context 'for group submissions' do
      it 'needs to be implemented'
    end
  end

  context 'submission points' do
    let(:submission) do
      sub = create :submission
      sub.submission_evaluation.update(evaluation_result: 20)
      sub
    end

    it 'updates the points after create' do
      exercise_registration = build(:exercise_registration, submission: submission, exercise: submission.exercise)
      expect(exercise_registration.points).to be_nil

      expect(exercise_registration.term_registration).to receive(:update_points!)
      exercise_registration.save
      expect(exercise_registration.points).to eq(20)
    end
  end
end
