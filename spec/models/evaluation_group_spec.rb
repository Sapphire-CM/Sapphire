require 'rails_helper'

RSpec.describe EvaluationGroup do
  describe 'associations' do
    it { is_expected.to belong_to(:rating_group) }
    it { is_expected.to belong_to(:submission_evaluation).touch(true) }
    it { is_expected.to have_many(:evaluations).dependent(:delete_all) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:rating_group) }
    it { is_expected.to validate_presence_of(:submission_evaluation) }
  end

  describe 'attributes' do
    it { is_expected.to define_enum_for(:status).with({ pending: 0, done: 1 }) }
  end

  describe 'delegation' do
    describe '#title' do
      let(:rating_group) { FactoryGirl.build(:rating_group) }
      let(:rating_title) { "A rating title" }

      it 'is delegated to #rating' do
        subject.rating_group = rating_group

        expect(rating_group).to receive(:title).and_return(rating_title)
        expect(subject.title).to eq(rating_title)
      end
    end
  end

  describe 'scoping' do
    pending '.ranked'
  end

  describe 'method' do
    pending '.create_for_submission_evaluation'
    pending '.create_for_submission_evaluation_and_rating_group'

    pending '#update_result!'
    pending '#calc_result'
    pending '#update_needs_review!'
  end
end