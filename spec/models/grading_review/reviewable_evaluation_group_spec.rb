require 'rails_helper'

RSpec.describe GradingReview::ReviewableEvaluationGroup do
  subject { described_class.new(evaluation_group: evaluation_group, evaluations: evaluations) }

  let(:evaluations) { [] }
  let(:evaluation_group) { instance_double(EvaluationGroup) }

  describe 'delegation' do
    it { is_expected.to delegate_method(:rating_group).to(:evaluation_group) }
    it { is_expected.to delegate_method(:rating_group_id).to(:evaluation_group) }
    it { is_expected.to delegate_method(:row_order).to(:rating_group) }
  end

  describe 'methods' do
    describe 'evaluations?' do
      let(:evaluation) { instance_double(Evaluation) }

      it 'returns false if evaluations are empty' do
        subject.evaluations = []

        expect(subject.evaluations?).to be_falsey
      end

      it 'returns true if evaluations are present' do
        subject.evaluations = [evaluation]

        expect(subject.evaluations?).to be_truthy
      end
    end

    describe '#sorted_evaluations' do
      let(:evaluations) {
        [
          instance_double(Evaluation, row_order: 0),
          instance_double(Evaluation, row_order: 2),
          instance_double(Evaluation, row_order: 1)
        ]
      }

      it 'returns the evaluations sorted by the row order' do
        expect(subject.sorted_evaluations).to eq([evaluations[0], evaluations[2], evaluations[1]])
      end
    end
  end

end