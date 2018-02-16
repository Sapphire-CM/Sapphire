require 'rails_helper'

describe ExerciseRegistration do
  describe 'db columns' do
    it { is_expected.to have_db_column(:points).of_type(:integer) }
    it { is_expected.to have_db_column(:individual_subtractions).of_type(:integer) }
    it { is_expected.to have_db_column(:outdated).of_type(:boolean).with_options(null: false, default: false) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:exercise) }
    it { is_expected.to belong_to(:submission) }
    it { is_expected.not_to belong_to(:student_group) }
    it { is_expected.to belong_to(:term_registration) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:exercise) }
    it { is_expected.to validate_presence_of(:term_registration) }
    it { is_expected.to validate_presence_of(:submission) }
    it { is_expected.to validate_numericality_of(:points).only_integer }
    it { is_expected.not_to validate_presence_of(:individual_subtractions) }
    it { is_expected.to validate_numericality_of(:individual_subtractions).is_less_than_or_equal_to(0).only_integer }
    it { is_expected.to validate_uniqueness_of(:term_registration_id).scoped_to([:exercise_id, :submission_id]) }
  end

  describe 'scoping' do
    describe '.recent' do
      let!(:recent_exercise_registrations) { FactoryGirl.create_list(:exercise_registration, 2, :recent) }
      let!(:outdated_exercise_registrations) { FactoryGirl.create_list(:exercise_registration, 2, :outdated) }

      it 'returns recent exercise registrations' do
        expect(described_class.recent).to match_array(recent_exercise_registrations)
      end
    end

    describe '.outdated' do
      let!(:recent_exercise_registrations) { FactoryGirl.create_list(:exercise_registration, 2, :recent) }
      let!(:outdated_exercise_registrations) { FactoryGirl.create_list(:exercise_registration, 2, :outdated) }

      it 'returns outdated exercise registrations' do
        expect(described_class.outdated).to match_array(outdated_exercise_registrations)
      end
    end
  end

  describe 'delegation' do
    it { is_expected.to delegate_method(:submission_evaluation).to(:submission) }
    it { is_expected.to delegate_method(:evaluation_result).to(:submission_evaluation) }
  end

  describe 'callbacks' do
    describe 'creation', :doing do
      let(:submission) do
        FactoryGirl.create(:submission).tap do |submission|
          submission.submission_evaluation.update(evaluation_result: 20)
        end
      end

      subject { FactoryGirl.build(:exercise_registration, submission: submission, exercise: submission.exercise) }

      it 'updates the points after create' do
        expect(subject.points).to be_nil
        expect(subject.term_registration).to receive(:update_points!)

        subject.save
        expect(subject.points).to eq(20)
      end

      it 'calls #mark_as_recent!' do
        subject.save
      end
    end

    describe 'destruction' do
      subject { FactoryGirl.create(:exercise_registration, submission: submission, exercise: submission.exercise) }
      let(:submission) { FactoryGirl.create(:submission) }
      let(:term_registration) { subject.term_registration }

      it 'calls #update_points! on term_registration' do
        expect(term_registration).to receive(:update_points!)

        subject.destroy
      end
    end

    describe 'changing a term_registration' do
      subject! { FactoryGirl.create(:exercise_registration, submission: submission, exercise: submission.exercise, term_registration: old_term_registration) }

      let(:term) { FactoryGirl.create(:term) }
      let(:exercise) { FactoryGirl.create(:exercise, term: term) }
      let(:submission) do
         FactoryGirl.create(:submission, exercise: exercise).tap do |submission|
           submission.submission_evaluation.update(evaluation_result: 42)
         end
       end

      let!(:old_term_registration) { FactoryGirl.create(:term_registration, term: term) }
      let!(:new_term_registration) { FactoryGirl.create(:term_registration, term: term) }

      it 'calls #update_points! on old term_registration' do
        old_term_registration.update(points: 21)
        subject.update(term_registration: new_term_registration)

        old_term_registration.reload
        expect(old_term_registration.points).to eq(0)
      end

      it 'calls #update_points! on new term_registration' do
        new_term_registration.update(points: 0)
        subject.update(term_registration: new_term_registration)

        new_term_registration.reload

        expect(new_term_registration.points).to eq(42)
      end
    end

    describe 'changing points', :doing do
      subject { FactoryGirl.create(:exercise_registration, points: 21) }

      let(:term_registration) { subject.term_registration }

      it 'calls #update_points! on term_registration if points are changed' do
        expect(term_registration).to receive(:update_points!)

        subject.update(points: 42)
      end

      it 'does not call #update_points! on term_registration if points do not change' do
        expect(term_registration).to receive(:update_points!)

        subject.update(points: 21)
      end
    end

    describe 'changing individual subtractions' do
      let(:term) { FactoryGirl.create(:term) }
      let(:term_registration) { FactoryGirl.create(:term_registration, term: term) }
      let(:exercise) { FactoryGirl.create(:exercise, term: term) }
      let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }

      subject { FactoryGirl.create(:exercise_registration, submission: submission, exercise: exercise, term_registration: term_registration) }

      before :each do
        submission.submission_evaluation.update(evaluation_result: 42)
      end

      it 'updates the points on save' do
        expect(subject.points).to eq(42)

        subject.update(individual_subtractions: -20)

        expect(subject.points).to eq(22)
      end
    end

    describe 'changing outdated', :doing do
      let(:term_registration) { subject.term_registration }
      let(:submission) { subject.submission }

      context 'on recent exercise registration' do
        subject { FactoryGirl.create(:exercise_registration, :recent, points: 21) }

        it 'calls #update_points! on term_registration' do
          expect(term_registration).to receive(:update_points!)

          subject.update(outdated: true)
        end

        it 'calls #update_outdated! on submission' do
          expect(submission).to receive(:update_outdated!)

          subject.update(outdated: true)
        end

        it 'does not call #update_points! on term_registration if outdated does not change' do
          expect(term_registration).not_to receive(:update_points!)

          subject.update(outdated: false)
        end

        it 'does not call #update_outdated! on submission if outdated does not change' do
          expect(submission).not_to receive(:update_outdated!)

          subject.update(outdated: false)
        end
      end

      context 'on outdated exercise registration' do
        subject { FactoryGirl.create(:exercise_registration, :outdated, points: 21) }

        let!(:similar_exercise_registration) { FactoryGirl.create(:exercise_registration, :recent, exercise: subject.exercise, term_registration: subject.term_registration) }
        let!(:exercise_registration_with_different_exercise) { FactoryGirl.create(:exercise_registration, :recent, term_registration: subject.term_registration) }
        let!(:exercise_registration_with_different_term_registration) { FactoryGirl.create(:exercise_registration, :recent, term_registration: subject.term_registration) }

        it 'calls #update_points! on term_registration' do
          expect(term_registration).to receive(:update_points!)

          subject.update(outdated: false)
        end

        it 'calls #update_outdated! on submission' do
          expect(submission).to receive(:update_outdated!)

          subject.update(outdated: false)
        end

        it 'updates similar exercise registrations to be outdated' do
          subject.update(outdated: false)

          expect(similar_exercise_registration.reload).to be_outdated
        end

        it 'does not call #update_points! on term_registration if outdated does not change' do
          expect(term_registration).not_to receive(:update_points!)

          subject.update(outdated: true)
        end

        it 'does not call #update_outdated! on submission if outdated does not change' do
          expect(submission).not_to receive(:update_outdated!)

          subject.update(outdated: true)
        end

        it 'does not update unrelated exercise registrations' do
          subject.update(outdated: false)

          expect(exercise_registration_with_different_exercise.reload).to be_recent
          expect(exercise_registration_with_different_term_registration.reload).to be_recent
        end
      end
    end
  end

  describe 'methods' do
    describe '#update_points' do
      let(:submission) { FactoryGirl.create(:submission) }
      let(:submission_evaluation) { submission.submission_evaluation }
      let(:evaluation_result) { 42 }

      it 'sets the result of the associated submission evaluation' do
        submission_evaluation.update(evaluation_result: evaluation_result)
        subject.submission = submission
        subject.points = 21

        subject.update_points

        expect(subject.points).to eq(evaluation_result)
      end

      it 'accounts for individual subtractions' do
        submission_evaluation.update(evaluation_result: evaluation_result)
        subject.submission = submission
        subject.individual_subtractions = -20

        subject.update_points

        expect(subject.points).to eq(22)
      end

      it 'does not allow points to get below 0 using individual subtractions' do
        submission_evaluation.update(evaluation_result: evaluation_result)
        subject.submission = submission
        subject.individual_subtractions = -100

        subject.update_points

        expect(subject.points).to eq(0)
      end

      it 'does not raise an error if no submission_evaluation is not present and sets the points to 0' do
        subject.submission = nil
        subject.points = 42

        expect do
          subject.update_points
        end.not_to raise_error

        expect(subject.points).to eq(0)
      end
    end

    describe '#update_points!' do
      it 'calls #update_points then #save!' do
        expect(subject).to receive(:update_points).ordered
        expect(subject).to receive(:save!).ordered

        subject.update_points!
      end
    end

    describe '#minimum_points_reached?' do
      let(:minimum_points) { 42 }
      let(:above_threshold_points) { 42 }
      let(:below_threshold_points) { 41 }

      let(:exercise_without_min_points) { FactoryGirl.build(:exercise, :without_minimum_points) }
      let(:exercise_with_min_points) { FactoryGirl.build(:exercise, :with_minimum_points, min_required_points: minimum_points) }

      it 'returns true if exercise does not require minimum points and points are below the threshold' do
        subject.exercise = exercise_without_min_points
        subject.points = below_threshold_points

        expect(subject.minimum_points_reached?).to be_truthy
      end

      it 'returns true if exercise does not require minimum points and points are above the threshold' do
        subject.exercise = exercise_without_min_points
        subject.points = above_threshold_points

        expect(subject.minimum_points_reached?).to be_truthy
      end

      it 'returns false if exercise requires minimum points and points are below the threshold' do
        subject.exercise = exercise_with_min_points
        subject.points = below_threshold_points

        expect(subject.minimum_points_reached?).to be_falsey
      end

      it 'returns true if exercise requires minimum points and points are above the threshold' do
        subject.exercise = exercise_with_min_points
        subject.points = above_threshold_points

        expect(subject.minimum_points_reached?).to be_truthy
      end
    end

    describe '#individual_subtractions?' do
      it 'returns true if individual_subtractions is less than 0' do
        subject.individual_subtractions = -1

        expect(subject.individual_subtractions?).to be_truthy
      end

      it 'returns false if individual_subtractions are 0' do
        subject.individual_subtractions = 0

        expect(subject.individual_subtractions?).to be_falsey
      end

      it 'returns false if individual_subtractions are nil' do
        subject.individual_subtractions = nil

        expect(subject.individual_subtractions?).to be_falsey
      end
    end

    describe '#recent?', :doing do
      it 'returns false if outdated is set to true' do
        subject.outdated = true

        expect(subject).not_to be_recent
      end

      it 'returns true if outdated is set to false' do
        subject.outdated = false

        expect(subject).to be_recent
      end
    end
  end
end
