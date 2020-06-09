require 'rails_helper'

RSpec.describe SubmissionEvaluation do
  describe 'db columns' do
    it { is_expected.to have_db_column(:evaluated_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:evaluation_result).of_type(:integer) }
    it { is_expected.to have_db_column(:plagiarized).of_type(:boolean).with_options(null: false, default: false) }
    it { is_expected.to have_db_column(:needs_review).of_type(:boolean).with_options(default: false) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:submission) }
    it { is_expected.to belong_to(:evaluator) }

    it { is_expected.to have_one(:student_group) }
    it { is_expected.to have_many(:evaluation_groups) }
    it { is_expected.to have_many(:evaluations).through(:evaluation_groups) }
    it { is_expected.to have_many(:ratings).through(:evaluations) }
    it { is_expected.to have_many(:rating_groups).through(:ratings) }
    it { is_expected.to have_many(:feedback_comments) }
    it { is_expected.to have_many(:internal_notes_comments) }
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
      let(:evaluation_groups) { FactoryGirl.create_list(:evaluation_group, 3, submission_evaluation: subject, needs_review: false) }
      let(:submission) { FactoryGirl.create(:submission) }

      subject { submission.submission_evaluation }

      it 'sets needs_review to true if an evaluation_groups needs_review' do
        evaluation_groups.second.update(needs_review: true)
        subject.evaluation_groups = evaluation_groups
        subject.needs_review = false

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
