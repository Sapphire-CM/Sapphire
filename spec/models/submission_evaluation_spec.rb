require 'rails_helper'

RSpec.describe SubmissionEvaluation do
  describe 'associations' do
    it { is_expected.to belong_to(:submission) }
    it { is_expected.to belong_to(:evaluator) }

    it { is_expected.to have_one(:student_group) }
    it { is_expected.to have_many(:evaluation_groups) }
    it { is_expected.to have_many(:evaluations).through(:evaluation_groups) }
    it { is_expected.to have_many(:ratings).through(:evaluations) }
    it { is_expected.to have_many(:rating_groups).through(:ratings) }
  end

  describe 'validations' do
    subject { FactoryGirl.build(:submission_evaluation) }

    it { is_expected.to validate_presence_of(:submission) }
    it { is_expected.to validate_uniqueness_of(:submission_id) }
  end

  describe 'scoping' do
    describe '.evaluated' do
      let(:submission_evaluations) { FactoryGirl.create_list(:submission_evaluation, 3, :evaluated) }
      let(:other_submission_evaluations) { FactoryGirl.create_list(:submission_evaluation, 3) }

      it 'returns submission_evaluations where an evaluator is present' do
        expect(described_class.evaluated).to match_array(submission_evaluations)
      end
    end

    describe '.not_evaluated' do
      let(:submission_evaluations) { FactoryGirl.create_list(:submission_evaluation, 3) }
      let(:other_submission_evaluations) { FactoryGirl.create_list(:submission_evaluation, 3, :evaluated) }

      it 'returns submission_evaluations where an evaluator is present' do
        expect(described_class.not_evaluated).to match_array(submission_evaluations)
      end
    end
  end

  describe 'methods' do
    pending '#calc_results!'
    pending '#update_plagiarized!'
    pending '#update_exercise_results'
    pending '#evaluation_for_rating'

    describe '#update_needs_review!' do
      let(:evaluation_groups) { FactoryGirl.build_list(:evaluation_group, 3, submission_evaluation: subject) }
      let(:submission) { FactoryGirl.create(:submission) }

      subject { submission.submission_evaluation }

      it 'sets needs_review to true if an evaluation_groups needs_review' do
        evaluation_groups.second.needs_review = true
        subject.evaluation_groups = evaluation_groups

        expect do
          subject.update_needs_review!
        end.to change(subject, :needs_review?).to(true)
      end

      it 'sets needs_review to false of no evaluation_groups needs_review' do
        subject.needs_review = true
        subject.evaluation_groups = evaluation_groups

        expect do
          subject.update_needs_review!
        end.to change(subject, :needs_review?).to(false)
      end
    end
  end
end
