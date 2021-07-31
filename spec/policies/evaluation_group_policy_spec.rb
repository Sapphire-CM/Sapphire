require 'rails_helper'

RSpec.describe EvaluationGroupPolicy do
  subject { described_class.new(account, evaluation_group) }

  context 'as admin' do
    let(:account) { FactoryBot.create(:account, :admin) }
    let(:evaluation_group) { FactoryBot.create(:evaluation_group) }

    it { is_expected.to permit_authorization :update }
  end

  %I(lecturer tutor).each do |role|
    context "as #{role}" do
      let(:account) { FactoryBot.create(:account, role) }

      context 'of term' do
        let(:term_registration) { account.term_registrations.first }
        let(:term) { term_registration.term }
        let(:exercise) { FactoryBot.create(:exercise, term: term)  }
        let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
        let(:submission_evaluation) { submission.submission_evaluation }
        let(:evaluation_group) { FactoryBot.create(:evaluation_group, submission_evaluation: submission_evaluation) }

        it { is_expected.to permit_authorization :update }
      end

      context 'of other term' do
        let(:evaluation_group) { FactoryBot.create(:evaluation_group) }

        it { is_expected.not_to permit_authorization :update }
      end
    end
  end

  context "as student" do
    let(:account) { FactoryBot.create(:account, :student) }

    context 'of term' do
      let(:term_registration) { account.term_registrations.first }
      let(:term) { term_registration.term }
      let(:exercise) { FactoryBot.create(:exercise, term: term)  }
      let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
      let(:submission_evaluation) { submission.submission_evaluation }
      let(:evaluation_group) { FactoryBot.create(:evaluation_group, submission_evaluation: submission_evaluation) }

      it { is_expected.not_to permit_authorization :update }
    end

    context 'of other term' do
      let(:evaluation_group) { FactoryBot.create(:evaluation_group) }

      it { is_expected.not_to permit_authorization :update }
    end
  end
end