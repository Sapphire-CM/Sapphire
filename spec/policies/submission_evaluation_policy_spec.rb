require 'rails_helper'

RSpec.describe SubmissionEvaluationPolicy do
  subject { described_class.new(account, submission_evaluation) }
  let(:submission) { FactoryBot.create(:submission) }
  let(:submission_evaluation) { submission.submission_evaluation }

  context 'as an admin' do
    let(:account) { FactoryBot.create(:account, :admin) }

    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:update) }
  end

  context 'as a lecturer' do
    let(:term) { submission.exercise.term }
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: account, term: term) }

    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:update) }
  end

  context 'as a tutor' do
    let(:term) { submission.exercise.term }
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, account: account, term: term) }

    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:update) }
  end

  context 'as a student' do
    let(:term) { exercise.term }
    let(:exercise) { submission.exercise }
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, account: account, term: term) }

    it { is_expected.not_to permit_authorization(:show) }
    it { is_expected.not_to permit_authorization(:update) }
  end

  context 'as a lecturer of another term' do
    let(:account) { FactoryBot.create(:account) }
    let(:another_term) { FactoryBot.create(:term) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, term: another_term) }

    it { is_expected.not_to permit_authorization(:show) }
    it { is_expected.not_to permit_authorization(:update) }
  end

  context 'as a tutor of another term' do
    let(:account) { FactoryBot.create(:account) }
    let(:another_term) { FactoryBot.create(:term) }
    let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: another_term) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, term: another_term, tutorial_group: tutorial_group) }

    it { is_expected.not_to permit_authorization(:show) }
    it { is_expected.not_to permit_authorization(:update) }
  end
end
