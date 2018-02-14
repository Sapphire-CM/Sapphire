require 'rails_helper'

RSpec.describe GradingReview::SubmissionReview do
  subject { described_class.new(exercise_registration: exercise_registration) }

  let(:exercise_registration) { instance_double(ExerciseRegistration) }

  describe 'delegation' do
    let(:submission) { instance_double(Submission, submission_assets: SubmissionAsset.none) }
    let(:exercise_registration) { instance_double(ExerciseRegistration, submission: submission) }

    it { is_expected.to delegate_method(:exercise).to(:exercise_registration) }
    it { is_expected.to delegate_method(:points).to(:exercise_registration) }
    it { is_expected.to delegate_method(:individual_subtractions).to(:exercise_registration) }
    it { is_expected.to delegate_method(:individual_subtractions?).to(:exercise_registration) }
    it { is_expected.to delegate_method(:submission).to(:exercise_registration) }
    it { is_expected.to delegate_method(:term_registration).to(:exercise_registration) }

    it { is_expected.to delegate_method(:title).to(:exercise).with_prefix(true) }
    it { is_expected.to delegate_method(:achievable_points).to(:exercise) }
    it { is_expected.to delegate_method(:submission_viewer?).to(:exercise) }

    it { is_expected.to delegate_method(:submission_evaluation).to(:submission) }
    it { is_expected.to delegate_method(:submitted_at).to(:submission) }

    it { is_expected.to delegate_method(:evaluations).to(:submission_evaluation) }

    it { is_expected.to delegate_method(:tutorial_group).to(:term_registration) }

    it 'delegates submission_assets to submission' do
      expect(submission).to receive(:submission_assets).and_return(SubmissionAsset.none)

      subject.submission_assets
    end
  end

  describe 'methods' do
    let(:exercise_registration) { instance_double(ExerciseRegistration, exercise: exercise, submission: submission) }
    let(:exercise) { instance_double(Exercise) }
    let(:submission) { instance_double(Submission, submission_evaluation: submission_evaluation) }
    let(:submission_evaluation) { instance_double(SubmissionEvaluation) }

    describe '.find_by_account_and_exercise' do
      let(:term) { FactoryGirl.create(:term) }
      let(:account) { term_registration.account }
      let(:term_registration) { FactoryGirl.create(:term_registration, :student, term: term) }
      let(:exercise) { FactoryGirl.create(:exercise, term: term) }
      let(:other_exercise) { FactoryGirl.create(:exercise, term: term) }
      let(:submission) { FactoryGirl.create(:submission) }
      let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, exercise: exercise, submission: submission, term_registration: term_registration) }

      it 'returns a new object if exercise registration does exist' do
        subject = described_class.find_by_account_and_exercise(account, exercise)

        expect(subject.exercise_registration).to eq(exercise_registration)
      end

      it 'raises ActiveRecord::RecordNotFound if no exercise registration exists' do
        expect do
          described_class.find_by_account_and_exercise(account, other_exercise)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    describe '#evaluations_visible_to_students' do
      let(:evaluations) do
        [
          instance_double(Evaluation, show_to_students?: true),
          instance_double(Evaluation, show_to_students?: false),
          instance_double(Evaluation, show_to_students?: true)
        ]
      end
      let(:visible_evaluations) { [evaluations.first, evaluations.third] }

      it 'returns all evaluations visible to students' do
        allow(submission_evaluation).to receive(:evaluations).and_return(evaluations)

        expect(subject.evaluations_visible_to_students).to match(visible_evaluations)
      end
    end

    describe '#reviewable_evaluation_groups' do
      let(:evaluations) do
        [
          instance_double(Evaluation, show_to_students?: true, evaluation_group: evaluation_groups[0]),
          instance_double(Evaluation, show_to_students?: false, evaluation_group: evaluation_groups[0]),
          instance_double(Evaluation, show_to_students?: true, evaluation_group: evaluation_groups[0]),
          instance_double(Evaluation, show_to_students?: true, evaluation_group: evaluation_groups[1]),
          instance_double(Evaluation, show_to_students?: false, evaluation_group: evaluation_groups[2])
        ]
      end
      let(:evaluation_groups) do
        [
          instance_double(EvaluationGroup, rating_group: rating_groups[0]),
          instance_double(EvaluationGroup, rating_group: rating_groups[1]),
          instance_double(EvaluationGroup, rating_group: rating_groups[2])
        ]
      end
      let(:rating_groups) do
        [
          instance_double(RatingGroup, row_order: 2),
          instance_double(RatingGroup, row_order: 1),
          instance_double(RatingGroup, row_order: 3),
        ]
      end

      before :each do
        allow(submission_evaluation).to receive(:evaluations).and_return(evaluations)
      end

      it 'returns reviewable evaluation groups ordered by row order of rating group' do
        groups = subject.reviewable_evaluation_groups

        expect(groups.first.evaluation_group).to eq(evaluation_groups[1])
        expect(groups.second.evaluation_group).to eq(evaluation_groups[0])
      end

      it 'assigns the correct evaluations to reviewable evaluation groups' do
        groups = subject.reviewable_evaluation_groups

        expect(groups.first.evaluations).to match([evaluations[3]])
        expect(groups.second.evaluations).to match([evaluations[0], evaluations[2]])
      end
    end

    describe '#deductions?' do
      let(:visible_evaluations) { [instance_double(Evaluation, show_to_students?: true), instance_double(Evaluation, show_to_students?: true)] }
      let(:invisible_evaluations) { [instance_double(Evaluation, show_to_students?: false), instance_double(Evaluation, show_to_students?: false)] }

      let(:submission) { instance_double(Submission, submission_evaluation: submission_evaluation) }
      let(:submission_evaluation) { instance_double(SubmissionEvaluation) }
      let(:exercise_registration) { instance_double(ExerciseRegistration, submission: submission) }

      it 'returns true if there are visible evaluations' do
        allow(submission_evaluation).to receive(:evaluations).and_return(visible_evaluations)
        allow(exercise_registration).to receive(:individual_subtractions?).and_return(false)

        expect(subject.deductions?).to be_truthy
      end

      it 'returns true if individial point deductions are present' do
        allow(submission_evaluation).to receive(:evaluations).and_return(invisible_evaluations)
        allow(exercise_registration).to receive(:individual_subtractions?).and_return(true)

        expect(subject.deductions?).to be_truthy
      end

      it 'returns false if there are neither visible evaluations nor individual point deductions' do
        allow(submission_evaluation).to receive(:evaluations).and_return(invisible_evaluations)
        allow(exercise_registration).to receive(:individual_subtractions?).and_return(false)

        expect(subject.deductions?).to be_falsey
      end
    end

    describe '#published?' do
      let(:term) { FactoryGirl.create(:term) }
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let(:term_registration) { FactoryGirl.create(:term_registration, :student, term: term, tutorial_group: tutorial_group) }
      let(:exercise) { FactoryGirl.create(:exercise, term: term) }
      let(:submission) { FactoryGirl.create(:submission, exercise: exercise)}
      let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, submission: submission, exercise: exercise, term_registration: term_registration) }

      let(:result_publication) { exercise.result_publications.first }

      it 'returns true if the result for given exercise_registration is published' do
        result_publication.publish!

        expect(subject).to be_published
      end

      it 'returns false if the result for given exercise_registration is not published' do
        result_publication.conceal!

        expect(subject).not_to be_published
      end

      it 'fetches the publication status once if it is not set' do
        subject.published = nil

        expect(submission).to receive(:result_published?).once

        subject.published?
        subject.published?
      end

      it 'does not fetch the publication status if it is set to true' do
        expect(submission).not_to receive(:result_published?)

        subject.published = true

        subject.published?
      end


      it 'does not fetch the publication status if it is set to false' do
        expect(submission).not_to receive(:result_published?)

        subject.published = false

        subject.published?
      end
    end

  end
end