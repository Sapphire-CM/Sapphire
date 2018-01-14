require 'rails_helper'

RSpec.describe SubmissionCreationService, type: :model do
  shared_examples "basic submission creation" do
    describe 'methods' do
      describe '#submission' do
        freeze_time

        it 'returns a valid submission' do
          expect(subject.submission).to be_valid
        end

        it 'sets the submission time to current time' do
          expect(subject.submission.submitted_at).to eq(now)
        end

        it 'sets the exercise' do
          expect(subject.submission.exercise).to eq(exercise)
        end

        it 'builds a valid submission' do
          expect(subject.submission).to be_valid
        end
      end

      describe '#save' do
        it 'calls #save on the submission' do
          expect(subject.submission).to receive(:save)

          subject.save
        end

        it 'creates a submission' do
          expect do
            subject.save
          end.to change(Submission, :count).by(1)
        end

        it 'creates an event' do
          expect do
            subject.save
          end.to change(Events::Submission::Created, :count).by(1)
        end

        it 'creates exercise registrations' do
          expect do
            subject.save
          end.to change(ExerciseRegistration, :count).by(expected_exercise_registration_count)
        end

        it 'does not create an event if submission is invalid' do
          allow(subject.submission).to receive(:valid?).and_return(false)

          expect do
            subject.save
          end.not_to change(Event, :count)
        end
      end
    end
  end

  shared_examples "group submission creation" do
    describe '#submission' do
      it 'sets the student group' do
        expect(subject.submission.student_group).to eq(student_group)
      end
    end
  end

  shared_examples "solitary submission creation" do
    describe '#submission' do
      it 'does not set the student group' do
        expect(subject.submission.student_group).to be_nil
      end
    end
  end


  shared_examples "staff submission creation" do
    describe '#submission' do
      it 'sets the staff member as submitter' do
        expect(subject.submission.submitter).to eq(staff_account)
      end
    end

    describe '#save' do
      it 'creates the event on behalf of the staff member' do
        subject.save

        expect(Event.last.account).to eq(staff_account)
      end
    end
  end

  describe 'methods' do
    describe '.new_student_submission' do
      let(:account) { instance_double Account }
      let(:exercise) { instance_double Exercise }

      it 'calls new with expected attributes' do
        expect(described_class).to receive(:new).with({creator: account, exercise: exercise})

        described_class.new_student_submission(account, exercise)
      end
    end

    describe '.new_staff_submission' do
      let(:staff_account) { instance_double Account }
      let(:exercise) { instance_double Exercise }
      let(:student_group) { instance_double StudentGroup }

      it 'calls new with expected attributes' do
        expect(described_class).to receive(:new).with({creator: staff_account, exercise: exercise, on_behalf_of: student_group})

        described_class.new_staff_submission(staff_account, student_group, exercise)
      end
    end
  end

  describe 'student submissions' do
    let(:exercise) { FactoryGirl.create(:exercise, :solitary_submission) }
    let(:term_registration) { FactoryGirl.create(:term_registration, :student, :with_student_group) }
    let(:student_group) { term_registration.student_group }
    let(:account) { term_registration.account }
    let(:term) { term_registration.term }

    let!(:fellow_term_registrations) { FactoryGirl.create_list(:term_registration, 2, :student, term: term, student_group: student_group, tutorial_group: term_registration.tutorial_group) }

    subject { described_class.new(creator: account, exercise: exercise) }

    context 'solitary exercise' do
      let(:exercise) { FactoryGirl.create(:exercise, :solitary_exercise, term: term) }

      it_behaves_like "solitary submission creation"
      it_behaves_like "basic submission creation" do
        let(:expected_exercise_registration_count) { 1 }
      end
    end

    context 'group exercise' do
      let(:exercise) { FactoryGirl.create(:exercise, :group_exercise, term: term) }

      it_behaves_like "group submission creation"
      it_behaves_like "basic submission creation" do
        let(:expected_exercise_registration_count) { 3 }
      end
    end
  end

  describe 'staff submissions on behalf of student term registration' do
    let(:term) { FactoryGirl.create(:term)}
    let(:staff_term_registration) { FactoryGirl.create(:term_registration, :tutor, term: term) }
    let(:staff_account) { staff_term_registration.account }
    let(:student_term_registration) { FactoryGirl.create(:term_registration, :student, :with_student_group, term: term) }
    let(:student_group) { student_term_registration.student_group }

    let!(:fellow_student_term_registrations) { FactoryGirl.create_list(:term_registration, 2, :student, term: term, student_group: student_group, tutorial_group: student_term_registration.tutorial_group) }

    subject { described_class.new(creator: staff_account, exercise: exercise, on_behalf_of: student_term_registration) }

    context 'solitary exercise' do
      let(:exercise) { FactoryGirl.create(:exercise, :solitary_exercise, term: term) }

      it_behaves_like "solitary submission creation"
      it_behaves_like "staff submission creation"
      it_behaves_like "basic submission creation" do
        let(:expected_exercise_registration_count) { 1 }
      end

      describe '#submission' do
        it 'builds the correct exercise registrations' do
          expect(subject.submission.exercise_registrations.first.term_registration).to eq(student_term_registration)
        end
      end
    end

    context 'group exercise' do
      let(:exercise) { FactoryGirl.create(:exercise, :group_exercise, term: term) }

      it_behaves_like "group submission creation"
      it_behaves_like "staff submission creation"
      it_behaves_like "basic submission creation" do
        let(:expected_exercise_registration_count) { 3 }
      end
    end
  end

  describe 'staff submissions on behalf of student group' do
    let(:term) { FactoryGirl.create(:term)}
    let(:staff_term_registration) { FactoryGirl.create(:term_registration, :tutor, term: term) }
    let(:staff_account) { staff_term_registration.account }
    let(:student_term_registration) { FactoryGirl.create(:term_registration, :student, :with_student_group, term: term) }
    let(:student_group) { student_term_registration.student_group }

    let!(:fellow_student_term_registrations) { FactoryGirl.create_list(:term_registration, 2, :student, term: term, student_group: student_group, tutorial_group: student_term_registration.tutorial_group) }

    subject { described_class.new(creator: staff_account, exercise: exercise, on_behalf_of: student_term_registration) }

    context 'group exercise' do
      let(:exercise) { FactoryGirl.create(:exercise, :group_exercise, term: term) }

      it_behaves_like "group submission creation"
      it_behaves_like "staff submission creation"
      it_behaves_like "basic submission creation" do
        let(:expected_exercise_registration_count) { 3 }
      end
    end
  end

end
