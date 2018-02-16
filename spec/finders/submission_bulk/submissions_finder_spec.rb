require 'rails_helper'

RSpec.describe SubmissionBulk::SubmissionsFinder do
  describe 'initialization' do
    let(:exercise) { instance_double(Exercise) }
    it 'accepts an exercise' do
      subject = described_class.new(exercise: exercise)

      expect(subject.exercise).to eq(exercise)
    end
  end

  describe 'methods' do
    subject { described_class.new(exercise: exercise) }

    describe '#find_submissions_for_subjects' do
      let(:term) { FactoryGirl.create(:term) }

      context 'with group exercise' do
        let(:exercise) { FactoryGirl.create(:exercise, :group_exercise, term: term) }
        let(:other_exercise) { FactoryGirl.create(:exercise, :group_exercise, term: term) }

        let(:student_group_1) { FactoryGirl.create(:student_group, term: term) }
        let(:student_group_2) { FactoryGirl.create(:student_group, term: term) }
        let(:student_group_3) { FactoryGirl.create(:student_group, term: term) }

        let!(:student_groups) { [student_group_1, student_group_2] }
        let!(:other_student_groups) { [student_group_3] }

        let(:submission_1) { FactoryGirl.create(:submission, exercise: exercise, student_group: student_group_1) }
        let(:submission_2) { FactoryGirl.create(:submission, exercise: exercise, student_group: student_group_2) }
        let(:submission_3) { FactoryGirl.create(:submission, exercise: exercise, exercise_attempt: exercise_attempt, student_group: student_group_2) }
        let(:submission_4) { FactoryGirl.create(:submission, exercise: other_exercise, student_group: student_group_3) }

        let!(:submissions) { [submission_1, submission_2, submission_3, submission_4]}

        let(:exercise_attempt) { FactoryGirl.create(:exercise_attempt, exercise: exercise) }

        it 'returns matching submissions indexed by student group' do
          expect(subject.find_submissions_for_subjects(student_groups)).to match({student_group_1 => submission_1, student_group_2 => submission_2})
        end

        it 'accounts for the exercise attempt' do
          subject.exercise_attempt = exercise_attempt

          expect(subject.find_submissions_for_subjects(student_groups)).to match({student_group_2 => submission_3})
        end

        it 'does not return submissions of other exercises' do
          expect(subject.find_submissions_for_subjects(other_student_groups)).to eq({})
        end
      end

      context 'with solitary exercise' do
        let(:exercise) { FactoryGirl.create(:exercise, :solitary_exercise, term: term) }
        let(:other_exercise) { FactoryGirl.create(:exercise, :solitary_exercise, term: term) }
        let(:exercise_attempt) { FactoryGirl.create(:exercise_attempt, exercise: exercise) }

        let(:student_term_registration_1) { FactoryGirl.create(:term_registration, term: term) }
        let(:student_term_registration_2) { FactoryGirl.create(:term_registration, term: term) }
        let(:student_term_registration_3) { FactoryGirl.create(:term_registration, term: term) }

        let!(:student_term_registrations) { [student_term_registration_1, student_term_registration_2] }
        let!(:other_student_term_registrations) { [student_term_registration_3] }

        let(:submission_1) { FactoryGirl.create(:submission, exercise: exercise) }
        let(:submission_2) { FactoryGirl.create(:submission, exercise: exercise) }
        let(:submission_3) { FactoryGirl.create(:submission, exercise: exercise, exercise_attempt: exercise_attempt) }
        let(:submission_4) { FactoryGirl.create(:submission, exercise: other_exercise) }
        let!(:submissions) { [submission_1, submission_2, submission_3]}

        let(:exercise_registration_1) { FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: student_term_registration_1, submission: submission_1)}
        let(:exercise_registration_2) { FactoryGirl.create(:exercise_registration, :outdated, exercise: exercise, term_registration: student_term_registration_2, submission: submission_2)}
        let(:exercise_registration_3) { FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: student_term_registration_2, submission: submission_4)}
        let(:exercise_registration_4) { FactoryGirl.create(:exercise_registration, :outdated, exercise: exercise, term_registration: student_term_registration_1, submission: submission_3)}
        let(:exercise_registration_5) { FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: student_term_registration_3, submission: submission_4)}

        let!(:exercise_registrations) { [exercise_registration_1, exercise_registration_2, exercise_registration_3] }
        let!(:other_exercise_registrations) { [exercise_registration_4, exercise_registration_5] }

        it 'returns matching submissions indexed by term registration' do
          expect(subject.find_submissions_for_subjects(student_term_registrations)).to match({student_term_registration_1 => submission_1, student_term_registration_2 => submission_2})
        end

        it 'accounts for the exercise attempt' do
          subject.exercise_attempt = exercise_attempt

          expect(subject.find_submissions_for_subjects(student_term_registrations)).to match({student_term_registration_1 => submission_3})
        end

        it 'does not return submissions of other exercises' do
          expect(subject.find_submissions_for_subjects(other_student_term_registrations)).to eq({})
        end
      end
    end
  end

end