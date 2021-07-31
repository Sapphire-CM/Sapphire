require 'rails_helper'

describe ExerciseRegistration do
  describe 'db columns' do
    it { is_expected.to have_db_column(:points).of_type(:integer) }
    it { is_expected.to have_db_column(:individual_subtractions).of_type(:integer) }
    it { is_expected.to have_db_column(:active).of_type(:boolean).with_options(null: false, default: true) }
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
    describe '.active' do
      let!(:active_exercise_registrations) { FactoryBot.create_list(:exercise_registration, 2, :active) }
      let!(:inactive_exercise_registrations) { FactoryBot.create_list(:exercise_registration, 2, :inactive) }

      it 'returns active exercise registrations' do
        expect(described_class.active).to match_array(active_exercise_registrations)
      end
    end

    describe '.inactive' do
      let!(:active_exercise_registrations) { FactoryBot.create_list(:exercise_registration, 2, :active) }
      let!(:inactive_exercise_registrations) { FactoryBot.create_list(:exercise_registration, 2, :inactive) }

      it 'returns inactive exercise registrations' do
        expect(described_class.inactive).to match_array(inactive_exercise_registrations)
      end
    end
  end

  describe 'delegation' do
    it { is_expected.to delegate_method(:submission_evaluation).to(:submission) }
    it { is_expected.to delegate_method(:evaluation_result).to(:submission_evaluation) }
  end

  describe 'callbacks' do
    describe 'creation' do
      let(:submission) do
        FactoryBot.create(:submission).tap do |submission|
          submission.submission_evaluation.update(evaluation_result: 20)
        end
      end

      subject { FactoryBot.build(:exercise_registration, submission: submission, exercise: submission.exercise) }

      let!(:similar_exercise_registration) { FactoryBot.create(:exercise_registration, :active, exercise: subject.exercise, term_registration: subject.term_registration) }
      let!(:exercise_registration_with_different_exercise) { FactoryBot.create(:exercise_registration, :active, term_registration: subject.term_registration) }
      let!(:exercise_registration_with_different_term_registration) { FactoryBot.create(:exercise_registration, :active, term_registration: subject.term_registration) }

      it 'updates the points after create' do
        expect(subject.points).to be_nil
        expect(subject.term_registration).to receive(:update_points!)

        subject.save
        expect(subject.points).to eq(20)
      end

      it 'marks similar exercise registrations as inactive' do
        subject.save

        expect(similar_exercise_registration.reload).to be_inactive
      end

      it 'does not mark unrelated exercise registrations as inactive' do
        subject.save

        expect(exercise_registration_with_different_exercise.reload).to be_active
        expect(exercise_registration_with_different_term_registration.reload).to be_active
      end
    end

    describe 'destruction' do
      subject { FactoryBot.create(:exercise_registration, submission: submission, exercise: submission.exercise) }
      let(:submission) { FactoryBot.create(:submission) }
      let(:term_registration) { subject.term_registration }

      it 'calls #update_points! on term_registration' do
        expect(term_registration).to receive(:update_points!)

        subject.destroy
      end
    end

    describe 'changing a term_registration' do
      subject! { FactoryBot.create(:exercise_registration, submission: submission, exercise: submission.exercise, term_registration: old_term_registration) }

      let(:term) { FactoryBot.create(:term) }
      let(:exercise) { FactoryBot.create(:exercise, term: term) }
      let(:submission) do
         FactoryBot.create(:submission, exercise: exercise).tap do |submission|
           submission.submission_evaluation.update(evaluation_result: 42)
         end
       end

      let!(:old_term_registration) { FactoryBot.create(:term_registration, term: term) }
      let!(:new_term_registration) { FactoryBot.create(:term_registration, term: term) }

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

    describe 'changing points' do
      subject { FactoryBot.create(:exercise_registration, points: 21) }

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
      let(:term) { FactoryBot.create(:term) }
      let(:term_registration) { FactoryBot.create(:term_registration, term: term) }
      let(:exercise) { FactoryBot.create(:exercise, term: term) }
      let(:submission) { FactoryBot.create(:submission, exercise: exercise) }

      subject { FactoryBot.create(:exercise_registration, submission: submission, exercise: exercise, term_registration: term_registration) }

      before :each do
        submission.submission_evaluation.update(evaluation_result: 42)
      end

      it 'updates the points on save' do
        expect(subject.points).to eq(42)

        subject.update(individual_subtractions: -20)

        expect(subject.points).to eq(22)
      end
    end

    describe 'changing active' do
      let(:term_registration) { subject.term_registration }
      let(:submission) { subject.submission }

      context 'on active exercise registration' do
        subject { FactoryBot.create(:exercise_registration, :active, points: 21) }

        it 'calls #update_points! on term_registration' do
          expect(term_registration).to receive(:update_points!)

          subject.update(active: false)
        end

        it 'calls #update_active! on submission' do
          expect(submission).to receive(:update_active!)

          subject.update(active: false)
        end

        it 'does not call #update_points! on term_registration if active does not change' do
          expect(term_registration).not_to receive(:update_points!)

          subject.update(active: true)
        end

        it 'does not call #update_active! on submission if active does not change' do
          expect(submission).not_to receive(:update_active!)

          subject.update(active: true)
        end
      end

      context 'on inactive exercise registration' do
        subject { FactoryBot.create(:exercise_registration, :inactive, points: 21) }

        let!(:similar_exercise_registration) { FactoryBot.create(:exercise_registration, :active, exercise: subject.exercise, term_registration: subject.term_registration) }
        let!(:exercise_registration_with_different_exercise) { FactoryBot.create(:exercise_registration, :active, term_registration: subject.term_registration) }
        let!(:exercise_registration_with_different_term_registration) { FactoryBot.create(:exercise_registration, :active, term_registration: subject.term_registration) }

        it 'calls #update_points! on term_registration' do
          expect(term_registration).to receive(:update_points!)

          subject.update(active: true)
        end

        it 'calls #update_active! on submission' do
          expect(submission).to receive(:update_active!)

          subject.update(active: true)
        end

        it 'updates similar exercise registrations to be inactive' do
          subject.update(active: true)

          expect(similar_exercise_registration.reload).to be_inactive
        end

        it 'does not call #update_points! on term_registration if active does not change' do
          expect(term_registration).not_to receive(:update_points!)

          subject.update(active: false)
        end

        it 'does not call #update_active! on submission if active does not change' do
          expect(submission).not_to receive(:update_active!)

          subject.update(active: false)
        end

        it 'does not update unrelated exercise registrations' do
          subject.update(active: true)

          expect(exercise_registration_with_different_exercise.reload).to be_active
          expect(exercise_registration_with_different_term_registration.reload).to be_active
        end
      end
    end
  end

  describe 'methods' do
    describe '#update_points' do
      let(:submission) { FactoryBot.create(:submission) }
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

      let(:exercise_without_min_points) { FactoryBot.build(:exercise, :without_minimum_points) }
      let(:exercise_with_min_points) { FactoryBot.build(:exercise, :with_minimum_points, min_required_points: minimum_points) }

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

    describe '#inactive?' do
      it 'returns false if active is set to true' do
        subject.active = true

        expect(subject.inactive?).to be_falsey
      end

      it 'returns true if active is set to false' do
        subject.active = false

        expect(subject.inactive?).to be_truthy
      end
    end
  end
end
