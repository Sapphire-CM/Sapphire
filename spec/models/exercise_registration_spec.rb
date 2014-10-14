require 'spec_helper'

describe ExerciseRegistration do
  it { should belong_to(:exercise)}
  it { should belong_to(:submission)}
  it { should_not belong_to(:student_group)}
  it { should belong_to(:term_registration)}
  it { should validate_presence_of(:exercise_id) }
  it { should validate_presence_of(:term_registration_id) }
  it { should_not validate_presence_of(:student_group_id) }
  it { should validate_presence_of(:submission_id) }
  it { should validate_numericality_of(:points).allow_nil.only_integer }

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
