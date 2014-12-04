require 'rails_helper'

describe ExerciseRegistration do
  it { is_expected.to belong_to(:exercise)}
  it { is_expected.to belong_to(:submission)}
  it { is_expected.not_to belong_to(:student_group)}
  it { is_expected.to belong_to(:term_registration)}
  it { is_expected.to validate_presence_of(:exercise) }
  it { is_expected.to validate_presence_of(:term_registration) }
  it { is_expected.to validate_presence_of(:submission) }
  it { is_expected.to validate_numericality_of(:points).only_integer }

  context "submission points" do
    let(:submission) do
      sub = create :submission
      sub.submission_evaluation.update(evaluation_result: 20)
      sub
    end

    it "should update the points after create" do
      exercise_registration = build(:exercise_registration, submission: submission, exercise: submission.exercise)
      expect(exercise_registration.points).to be_nil

      expect(exercise_registration.term_registration).to receive(:update_points!)
      exercise_registration.save
      expect(exercise_registration.points).to eq(20)
    end
  end
end
