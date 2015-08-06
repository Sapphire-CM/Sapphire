require 'rails_helper'

RSpec.describe SubmissionEvaluation do
  pending 'further specs'

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
end
