require 'rails_helper'

RSpec.describe Submission do
  subject { FactoryBot.build(:submission) }

  describe 'db columns' do
    it { is_expected.to have_db_column(:submitted_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:active).of_type(:boolean).with_options(null: false, default: true) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:filesystem_size).of_type(:integer) }
  end

  describe 'associations' do
    it { is_expected.to belong_to :exercise }
    it { is_expected.to belong_to :submitter }
    it { is_expected.to belong_to :student_group }
    it { is_expected.to belong_to(:exercise_attempt) }
    it { is_expected.to have_one(:submission_evaluation).dependent(:destroy) }
    it { is_expected.to have_many(:exercise_registrations).dependent(:destroy).inverse_of(:submission) }
    it { is_expected.to have_many(:term_registrations).through(:exercise_registrations) }
    it { is_expected.to have_many(:associated_student_groups).through(:term_registrations) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:exercise) }
    it { is_expected.to validate_presence_of(:submitter) }
    it { is_expected.to validate_presence_of(:submitted_at) }

    describe 'student group uniqueness' do
      context "with student group" do
        let(:student_group) { FactoryBot.create(:student_group) }
        subject { FactoryBot.build(:submission, student_group: student_group) }

        it { is_expected.to validate_uniqueness_of(:student_group).scoped_to([:exercise_id, :exercise_attempt_id]) }
      end

      context "without student group" do
        subject { FactoryBot.build(:submission, student_group: nil) }

        it { is_expected.not_to validate_uniqueness_of(:student_group) }
      end
    end

    it 'validates size of all submission_assets combined must be below the maximum allowed size of the exercise'
  end

  describe 'delegation' do
    it { is_expected.to delegate_method(:submission_viewer?).to(:exercise) }
    it { is_expected.to delegate_method(:enable_multiple_attempts?).to(:exercise) }
  end

  describe 'scoping' do
    describe '.for_term' do
      let!(:term) { FactoryBot.create(:term) }
      let!(:exercise) { FactoryBot.create(:exercise, term: term) }
      let!(:another_exercise) { FactoryBot.create(:exercise) }
      let!(:submissions) { FactoryBot.create_list(:submission, 3, exercise: exercise) }
      let!(:other_submissions) { FactoryBot.create_list(:submission, 3, exercise: another_exercise) }

      it 'returns only submissions associated to the given term' do
        expect(described_class.for_term(term)).to match_array(submissions)
      end
    end

    describe '.active' do
      let!(:inactive_submissions) { FactoryBot.create_list(:submission, 3, :inactive) }
      let!(:active_submissions) { FactoryBot.create_list(:submission, 3, :active) }

      it 'returns active submissions' do
        expect(Submission.active).to match_array(active_submissions)
      end
    end

    describe '.inactive' do
      let!(:inactive_submissions) { FactoryBot.create_list(:submission, 3, :inactive) }
      let!(:active_submissions) { FactoryBot.create_list(:submission, 3, :active) }

      it 'returns inactive submissions' do
        expect(Submission.inactive).to match_array(inactive_submissions)
      end
    end

    describe '.for_exercise' do
      let(:exercise) { FactoryBot.create(:exercise) }
      let(:another_exercise) { FactoryBot.create(:exercise) }
      let!(:submissions) { FactoryBot.create_list(:submission, 3, exercise: exercise)}
      let!(:other_submissions) { FactoryBot.create_list(:submission, 3, exercise: another_exercise)}

      it 'returns submissions for given exercise' do
        expect(described_class.for_exercise(exercise)).to match_array(submissions)
      end
    end

    describe '.for_tutorial_group' do
      let!(:term) { FactoryBot.create(:term) }
      let!(:exercise) { FactoryBot.create(:exercise, term: term) }

      let!(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
      let!(:term_registrations) { FactoryBot.create_list(:term_registration, 3, :student, term: term, tutorial_group: tutorial_group) }
      let!(:exercise_registrations) { term_registrations.map { |tr| FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: tr)} }
      let!(:submissions) { exercise_registrations.map(&:submission) }

      let!(:another_tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
      let!(:other_term_registrations) { FactoryBot.create_list(:term_registration, 3, :student, term: term, tutorial_group: another_tutorial_group) }
      let!(:other_exercise_registrations) { other_term_registrations.map { |tr| FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: tr)} }
      let!(:other_submissions) { other_exercise_registrations.map(&:submission) }

      it 'returns submissions for given tutorial group' do
        expect(described_class.for_tutorial_group(tutorial_group)).to match_array(submissions)
      end
    end

    describe '.for_student_group' do
      let!(:student_group) { FactoryBot.create(:student_group) }
      let!(:another_student_group) { FactoryBot.create(:student_group) }
      let!(:submissions) { FactoryBot.create_list(:submission, 3, student_group: student_group) }
      let!(:other_submissions) { FactoryBot.create_list(:submission, 3, student_group: another_student_group) }

      it 'returns submissions submitted by given student group' do
        expect(described_class.for_student_group(student_group)).to match_array(submissions)
      end
    end

    describe '.for_account' do
      let!(:account) { FactoryBot.create(:account) }
      let!(:term_registrations) { FactoryBot.create_list(:term_registration, 3, account: account) }
      let!(:exercise_registrations) { term_registrations.map { |tr| FactoryBot.create(:exercise_registration, term_registration: tr) } }
      let!(:submissions) { exercise_registrations.map(&:submission) }

      let!(:another_account) { FactoryBot.create(:account) }
      let!(:other_term_registrations) { FactoryBot.create_list(:term_registration, 3, account: another_account) }
      let!(:other_exercise_registrations) { other_term_registrations.map { |tr| FactoryBot.create(:exercise_registration, term_registration: tr) } }
      let!(:other_submissions) { other_exercise_registrations.map(&:submission) }

      it 'returns submissions associated with given account' do
        expect(described_class.for_account(account)).to match_array(submissions)
      end
    end

    describe '.unmatched' do
      let!(:submissions) { FactoryBot.create_list(:submission, 3) }
      let!(:other_submissions) { FactoryBot.create_list(:submission, 3, :with_exercise_registrations) }

      it 'returns submissions where no exercise registrations are set' do
        expect(described_class.unmatched).to match_array(submissions)
      end
    end

    describe '.with_evaluation' do
      let!(:submissions) { FactoryBot.create_list(:submission, 3, :evaluated) }
      let!(:other_submissions) { FactoryBot.create_list(:submission, 3) }

      it 'returns submissions where evaluator of submission evaluation is present' do
        expect(described_class.with_evaluation).to match_array(submissions)
      end
    end

    describe '.ordered_by_student_group' do
      let!(:first_student_group) { FactoryBot.create(:student_group, title: 'Group 1') }
      let!(:second_student_group) { FactoryBot.create(:student_group, title: 'Group 2') }
      let!(:third_student_group) { FactoryBot.create(:student_group, title: 'Group 3') }

      # order of lines is important here!
      let!(:second_submission) { FactoryBot.create(:submission, student_group: second_student_group) }
      let!(:first_submission) { FactoryBot.create(:submission, student_group: first_student_group) }
      let!(:third_submission) { FactoryBot.create(:submission, student_group: third_student_group) }

      it 'orders submissions by title of student group' do
        expect(described_class.ordered_by_student_group).to match([first_submission, second_submission, third_submission])
      end
    end

    describe '.ordered_by_exercises' do
      let!(:first_exercise) { FactoryBot.create(:exercise, row_order: 0) }
      let!(:second_exercise) { FactoryBot.create(:exercise, row_order: 1) }
      let!(:third_exercise) { FactoryBot.create(:exercise, row_order: 2) }

      # order of lines is important here!
      let!(:second_submission) { FactoryBot.create(:submission, exercise: second_exercise) }
      let!(:first_submission) { FactoryBot.create(:submission, exercise: first_exercise) }
      let!(:third_submission) { FactoryBot.create(:submission, exercise: third_exercise) }

      it 'returns submissions ordered by exercise title' do
        expect(described_class.ordered_by_exercises).to match([first_submission, second_submission, third_submission])
      end
    end
  end

  describe 'callbacks' do
    let(:term) { FactoryBot.create(:term) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:term_registration) { FactoryBot.create(:term_registration, :student, term: term) }
    let(:exercise_registration) { FactoryBot.build(:exercise_registration, exercise: exercise, submission: subject, term_registration: term_registration) }

    describe 'after_create' do
      subject { FactoryBot.build(:submission, exercise: exercise) }

      it 'calls #create_submission_evaluation after creating a record' do
        expect(subject).to receive(:create_submission_evaluation!)
        subject.save
      end

      it 'calls #update_points! on exercise_registrations' do
        subject.exercise_registrations = [exercise_registration]

        expect(exercise_registration).to receive(:update_points!)

        subject.save
      end
    end

    describe 'after_update' do
      describe 'changing #active' do
        subject { FactoryBot.create(:submission, :inactive, exercise: exercise) }

        let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, submission: subject, term_registration: term_registration) }

        it 'calls #update_points! on term_registrations' do
          subject.exercise_registrations = [exercise_registration]

          expect(term_registration).to receive(:update_points!)
          subject.update(active: true)

          expect(term_registration).to receive(:update_points!)
          subject.update(active: false)
        end

        it 'does not call #update_points if active does not change' do
          expect(term_registration).not_to receive(:update_points!)
          subject.update(submitted_at: 3.days.ago)
        end
      end
    end
  end

  describe 'attributes' do
    it { is_expected.to accept_nested_attributes_for(:exercise_registrations).allow_destroy(true) }
  end

  describe 'methods' do
    describe '#evaluated?' do
      subject { FactoryBot.create(:submission) }

      it 'returns true if submission evaluation is present' do
        expect(subject.submission_evaluation).to be_present
        expect(subject).to be_evaluated
      end

      it 'returns false if submission evaluation is absent' do
        subject.submission_evaluation = nil
        expect(subject).not_to be_evaluated
      end
    end

    describe '#result_published?' do
      let(:term) { FactoryBot.create(:term) }
      let(:exercise) { FactoryBot.create(:exercise, term: term) }
      let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
      let(:result_publication) { ResultPublication.for(tutorial_group: tutorial_group, exercise: exercise) }


      context 'published results' do
        let!(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, tutorial_group: tutorial_group) }
        let!(:exercise_registration) { FactoryBot.create(:exercise_registration, term_registration: term_registration, exercise: exercise, submission: subject) }
        let!(:another_tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
        let!(:another_term_registration) { FactoryBot.create(:term_registration, :student, term: term, tutorial_group: another_tutorial_group) }
        let!(:another_exercise_registration) { FactoryBot.create(:exercise_registration, term_registration: another_term_registration, exercise: exercise, submission: subject) }

        subject { FactoryBot.create(:submission, exercise: exercise) }

        it 'returns true, when results for any of the associated tutorial groups are published' do
          result_publication.publish!
          subject.reload
          expect(subject.result_published?).to be_truthy
        end
      end

      context 'unpublished results' do
        let!(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, tutorial_group: tutorial_group) }
        let!(:exercise_registration) { FactoryBot.create(:exercise_registration, term_registration: term_registration, exercise: exercise, submission: subject) }

        subject { FactoryBot.create(:submission, exercise: exercise) }

        it 'returns false, when results are concealed for all associated tutorial groups' do
          result_publication.conceal!
          subject.reload
          expect(subject.result_published?).to be_falsey
        end
      end
    end

    describe '#visible_for_student?' do
      subject { FactoryBot.create(:submission, exercise: exercise) }
      let(:account) { FactoryBot.create(:account) }
      let(:another_account) { FactoryBot.create(:account) }

      let(:term) { FactoryBot.create(:term) }
      let(:exercise) { FactoryBot.create(:exercise, term: term) }
      let(:term_registration) { FactoryBot.create(:term_registration, term: term, account: account) }
      let!(:exercise_registration) { FactoryBot.create(:exercise_registration, term_registration: term_registration, exercise: exercise, submission: subject) }

      it 'returns true if a term_registration for given account is associated with submission' do
        expect(subject.visible_for_student?(account)).to be_truthy
      end

      it 'returns false if a term_registration for given account is not associated with submission' do
        expect(subject.visible_for_student?(another_account)).to be_falsey
      end
    end

    describe '#inactive?' do
      it 'returns true if subject is not active' do
        subject.active = false

        expect(subject.inactive?).to be_truthy
      end

      it 'returns false if subject is active' do
        subject.active = true

        expect(subject.inactive?).to be_falsey
      end
    end

    describe '#tree' do
      subject { FactoryBot.create(:submission, :with_basic_structure) }

      it 'returns a submission tree created by the SubmissionStructureService' do
        expect(subject.tree).to be_a(SubmissionStructure::Tree)
      end

      it 'sets submission of submission tree' do
        expect(subject.tree.submission).to eq(subject)
      end

      it 'sets the base_directory_name to "submission"' do
        expect(subject.tree.base_directory_name).to eq("submission")
      end

      it 'memoizes the returned tree' do
        first_tree = subject.tree
        second_tree = subject.tree

        expect(first_tree.object_id).to eq(second_tree.object_id)
      end
    end

    describe '#modifiable_by_students?' do
      let(:course) { FactoryBot.build(:course)}
      let(:term) { FactoryBot.build(:term, course: course) }
      let(:exercise) { FactoryBot.build(:exercise, term: term) }

      subject { FactoryBot.build(:submission, :active, exercise: exercise) }

      before :each do
        allow(exercise).to receive(:before_late_deadline?).and_return(true)
      end

      it 'returns true if submission is modifiable' do
        allow(subject).to receive(:active?).and_return(true)
        allow(exercise).to receive(:before_late_deadline?).and_return(true)
        allow(exercise).to receive(:enable_student_uploads?).and_return(true)
        allow(course).to receive(:locked?).and_return(false)

        expect(subject.modifiable_by_students?).to be_truthy
      end

      it 'returns false if submission is inactive' do
        expect(subject.modifiable_by_students?).to be_truthy

        subject.active = false

        expect(subject.modifiable_by_students?).to be_falsey
      end

      it 'returns false if deadline has passed' do
        expect(subject.modifiable_by_students?).to be_truthy

        allow(exercise).to receive(:before_late_deadline?).and_return(false)

        expect(subject.modifiable_by_students?).to be_falsey
      end

      it 'returns false if student uploads are disabled' do
        expect(subject.modifiable_by_students?).to be_truthy

        exercise.enable_student_uploads = false

        expect(subject.modifiable_by_students?).to be_falsey
      end

      it 'returns false if course is locked' do
        expect(subject.modifiable_by_students?).to be_truthy

        course.locked = true

        expect(subject.modifiable_by_students?).to be_falsey
      end
    end

    describe '#submission_assets_changed?' do
      subject { FactoryBot.build(:submission) }
      let!(:submission_asset) { FactoryBot.build(:submission_asset, submission: subject)}

      before :each do
        allow(subject).to receive(:submission_assets).and_return([submission_asset])
      end

      it 'returns false if nothing changed' do
        allow(submission_asset).to receive(:new_record?).and_return(false)
        allow(submission_asset).to receive(:changed?).and_return(false)
        allow(submission_asset).to receive(:marked_for_destruction?).and_return(false)

        expect(subject.submission_assets_changed?).to be_falsey
      end

      it 'returns true if submission asset was added' do
        expect(submission_asset).to receive(:new_record?).and_return(true)

        allow(submission_asset).to receive(:changed?).and_return(false)
        allow(submission_asset).to receive(:marked_for_destruction?).and_return(false)
        # expect(subject.submission_assets_changed?).to be_truthy
        subject.submission_assets_changed?
      end

      it 'returns true if submission asset was updated' do
        expect(submission_asset).to receive(:changed?).and_return(true)

        allow(submission_asset).to receive(:new_record?).and_return(false)
        allow(submission_asset).to receive(:marked_for_destruction?).and_return(false)

        expect(subject.submission_assets_changed?).to be_truthy
      end

      it 'returns true if submission asset was removed' do
        expect(submission_asset).to receive(:marked_for_destruction?).and_return(true)

        allow(submission_asset).to receive(:new_record?).and_return(false)
        allow(submission_asset).to receive(:changed?).and_return(false)

        expect(subject.submission_assets_changed?).to be_truthy
      end
    end

    describe '#set_exercise_of_exercise_registrations!' do
      let(:exercise) { FactoryBot.build(:exercise) }
      let(:other_exercise) { FactoryBot.build(:exercise) }
      let(:exercise_registrations) { FactoryBot.build_list(:exercise_registration, 3, submission: subject, exercise: other_exercise) }

      subject { FactoryBot.build(:submission, exercise: exercise) }

      it 'assigns the submissions exercise to the exercise registrations\' exercise' do
        subject.exercise_registrations = exercise_registrations

        subject.set_exercise_of_exercise_registrations!

        exercise_registrations.each do |exercise_registration|
          expect(exercise_registration.exercise).to eq(exercise)
        end
      end
    end

    describe '#update_active' do
      subject { FactoryBot.create(:submission) }

      let(:exercise_registrations) { FactoryBot.create_list(:exercise_registration, 3, submission: subject, exercise: subject.exercise) }

      before :each do
        subject.exercise_registrations = exercise_registrations
      end

      it 'sets active to false if one exercise_registration is inactive' do
        exercise_registrations.second.update(active: false)

        subject.active = true
        subject.update_active

        expect(subject).not_to be_active
      end

      it 'sets active to true if all exercise_registration are active' do
        exercise_registrations.each { |er| er.update(active: true) }

        subject.active = false
        subject.update_active

        expect(subject).to be_active
      end
    end

    describe '#update_active!' do
      it 'calls #update_active then #save!' do
        expect(subject).to receive(:update_active).ordered
        expect(subject).to receive(:save!).ordered

        subject.update_active!
      end
    end

    describe '#mark_as_active!' do
      subject { FactoryBot.create(:submission, exercise: exercise) }

      let(:exercise) { FactoryBot.create(:exercise) }
      let(:exercise_registration) { FactoryBot.create(:exercise_registration, :inactive, exercise: exercise, submission: subject) }

      before :each do
        subject.exercise_registrations = [exercise_registration]
      end

      it 'updates all exercise registrations to be active' do
        subject.mark_as_active!

        expect(exercise_registration.reload).to be_active
      end

      it 'marks the submission as active' do
        subject.active = false

        subject.mark_as_active!

        expect(subject).to be_active
      end
    end
  end
end
