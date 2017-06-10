require 'rails_helper'

RSpec.describe Evaluation do
  describe 'scoping' do
    pending '.ranked'
    pending '.for_submission'
    pending '.for_exercise'
    pending '.automatically_checked'
  end

  describe 'methods' do
    pending '.create_for_evaluation_group'
    pending '.create_for_rating'
    pending '#update_result!'

    describe '#points' do
      it 'is expected to return 0' do
        expect(subject.points).to eq(0)
      end
    end

    describe '#percent' do
      it 'is expected to return 0' do
        expect(subject.percent).to eq(1)
      end
    end
  end
end