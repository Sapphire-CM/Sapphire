require 'rails_helper'

RSpec.describe EvaluationPolicy do
  subject { described_class.new(account, evaluation) }

  context 'as admin' do
    let(:account) { FactoryBot.create(:account, :admin) }
    let(:exercise) { FactoryBot.create(:exercise) }
    let(:rating_group) { FactoryBot.create(:rating_group, exercise: exercise) }
    let!(:rating) { FactoryBot.create(:fixed_points_deduction_rating, rating_group: rating_group) }
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:submission_evaluation) { submission.submission_evaluation }
    let(:evaluation) { submission_evaluation.evaluations.first }

    it { is_expected.to permit_authorization :update }
  end

  %I(lecturer tutor).each do |role|
    context "as #{role}" do
      let(:account) { FactoryBot.create(:account, role) }

      let(:exercise) { FactoryBot.create(:exercise, term: term) }
      let(:rating_group) { FactoryBot.create(:rating_group, exercise: exercise) }
      let!(:rating) { FactoryBot.create(:fixed_points_deduction_rating, rating_group: rating_group) }
      let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
      let(:submission_evaluation) { submission.submission_evaluation }
      let(:evaluation) { submission_evaluation.evaluations.first }

      context 'of term' do
        let(:term_registration) { account.term_registrations.first }
        let(:term) { term_registration.term }

        it { is_expected.to permit_authorization :update }
      end

      context 'of other term' do
        let(:term) { FactoryBot.create(:term) }

        it { is_expected.not_to permit_authorization :update }
      end
    end
  end

  context "as student" do
    let(:account) { FactoryBot.create(:account, :student) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:rating_group) { FactoryBot.create(:rating_group, exercise: exercise) }
    let!(:rating) { FactoryBot.create(:fixed_points_deduction_rating, rating_group: rating_group) }
    let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
    let(:submission_evaluation) { submission.submission_evaluation }
    let(:evaluation) { submission_evaluation.evaluations.first }

    context 'of term' do
      let(:term_registration) { account.term_registrations.first }
      let(:term) { term_registration.term }

      it { is_expected.not_to permit_authorization :update }
    end

    context 'of other term' do
      let(:term) { FactoryBot.create(:term) }

      it { is_expected.not_to permit_authorization :update }
    end
  end
end