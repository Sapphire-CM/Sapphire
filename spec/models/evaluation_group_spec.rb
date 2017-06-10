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

    describe '.needing_review' do
      let!(:evaluation_groups_to_review) { FactoryGirl.create_list(:evaluation_group, 3, needs_review: true) }
      let!(:evaluation_groups_not_to_review) { FactoryGirl.create_list(:evaluation_group, 3, needs_review: false) }

      it 'returns evaluation_groups where needs_review is true' do
        expect(described_class.needing_review).to match_array(evaluation_groups_to_review)
      end

    end
  end

  describe 'method' do
    pending '.create_for_submission_evaluation'
    pending '.create_for_submission_evaluation_and_rating_group'

    pending '#update_result!'
    pending '#calc_result'

    describe '#update_needs_review!' do
      let(:evaluations) { FactoryGirl.build_list(:fixed_evaluation, 3, evaluation_group: subject) }

      subject { FactoryGirl.create(:evaluation_group) }

      it 'sets needs_review to true if an evaluation needs_review' do
        evaluations.second.needs_review = true
        subject.evaluations = evaluations

        expect do
          subject.update_needs_review!
        end.to change(subject, :needs_review?).to(true)
      end

      it 'sets needs_review to false of no evaluation needs_review' do
        subject.needs_review = true
        subject.evaluations = evaluations

        expect do
          subject.update_needs_review!
        end.to change(subject, :needs_review?).to(false)
      end
    end
  end

  describe 'callbacks' do
    describe 'changing needs_review' do
      subject { FactoryGirl.create(:evaluation_group) }

      it 'calls #update_needs_review! on submission_evaluation' do
        expect(subject.submission_evaluation).to receive(:update_needs_review!)

        subject.needs_review = true
        subject.save
      end
    end
  end
end