require 'rails_helper'

RSpec.describe SubmissionCreationService do
  let(:term_registration) { create(:term_registration, :student, :with_student_group) }
  let(:term) { term_registration.term }
  let(:account) { term_registration.account }
  let(:exercise) { create(:exercise, term: term) }
  let(:submission) { Submission.new(exercise: exercise) }
  let(:student_group) { term_registration.student_group }

  subject { SubmissionCreationService.new(account, submission) }

  describe '.initialize_submission_with_exercise' do
    it 'initializes a new submission and adds the exercise' do
      submission = described_class.initialize_submission_with_exercise(account, exercise)

      expect(submission).to be_a(Submission)
      expect(submission.exercise).to equal(exercise)
      expect(submission.exercise_registrations.map(&:term_registration)).to include(term_registration)
    end
  end

  describe '.new_with_exercise' do
    it 'initializes a new submission and adds the exercise' do
      service = described_class.new_with_exercise(account, exercise)
      expect(service).to be_a(described_class)
      expect(service.model).to be_a(Submission)
      expect(service.model.exercise).to equal(exercise)
      expect(service.model.exercise_registrations.map(&:term_registration)).to include(term_registration)
    end
  end

  context 'solitary submissions' do
    let(:exercise) { create(:exercise, term: term) }

    describe '#model' do
      freeze_time

      it 'returns the set up submission' do
        expect(subject.model).to eq(submission)
        expect(submission.submitter).to eq(account)
        expect(submission.submitted_at).to eq(now)
      end
    end

    describe '#valid?' do
      it 'sets up submission correctly' do
        expect(subject.valid?).to be_truthy
        expect(submission.valid?).to be_truthy
      end
    end

    describe '#save' do
      it 'creates a ExerciseRegistration and an Event' do
        expect do
          expect do
            subject.save
          end.to change(ExerciseRegistration, :count).by(1)
        end.to change(Events::Submission::Created, :count).by(1)

        er = ExerciseRegistration.last
        expect(er.term_registration).to eq(term_registration)
        expect(er.submission).to eq(submission)
        expect(er.exercise).to eq(exercise)

        event = Event.last
        expect(event).to be_a(Events::Submission::Created)
        expect(event.file_count).to eq(0)
      end
    end
  end

  context 'group submissions' do
    let(:tutorial_group) { term_registration.tutorial_group }
    let(:exercise) { create(:exercise, :group_exercise, term: term) }

    describe '#save' do
      it 'creates a ExerciseRegistration and an Event' do
        create_list(:term_registration, 3, student_group: student_group, term: term, tutorial_group: tutorial_group)
        term_registration.reload

        expect do
          expect do
            subject.save
          end.to change(ExerciseRegistration, :count).by(4)
        end.to change(Events::Submission::Created, :count).by(1)

        ExerciseRegistration.last(4).each do |er|
          expect(er.submission).to eq(submission)
          expect(er.exercise).to eq(exercise)
        end

        event = Event.last
        expect(event).to be_a(Events::Submission::Created)
        expect(event.file_count).to eq(0)
      end
    end
  end
end
