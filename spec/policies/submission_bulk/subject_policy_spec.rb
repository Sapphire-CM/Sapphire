require 'rails_helper'

RSpec.describe BulkGradings::SubjectPolicy, :doing do
  subject { described_class.new(account, policy_record) }

  let(:policy_record) { described_class.policy_record_with(exercise: exercise) }
  let(:term) { exercise.term }

  context 'exercise allowing bulk management' do
    let(:exercise) { FactoryBot.create(:exercise, enable_bulk_submission_management: true) }

    context 'as an admin' do
      let(:account) { FactoryBot.create(:account, :admin) }

      it { is_expected.to permit_authorization(:index) }
    end

    context 'as a lecturer' do
      let(:account) { FactoryBot.create(:account) }
      let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: account, term: term) }

      it { is_expected.to permit_authorization(:index) }
    end

    context 'as a tutor' do
      let(:account) { FactoryBot.create(:account) }
      let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, account: account, term: term) }

      it { is_expected.to permit_authorization(:index) }
    end

    context 'as a student' do
      let(:account) { FactoryBot.create(:account) }
      let!(:term_registration) { FactoryBot.create(:term_registration, :student, account: account, term: term) }

      it { is_expected.not_to permit_authorization(:index) }
    end
  end

  context 'exercise disallowing bulk management' do
    let(:exercise) { FactoryBot.create(:exercise, enable_bulk_submission_management: false) }

    context 'as an admin' do
      let(:account) { FactoryBot.create(:account, :admin) }

      it { is_expected.not_to permit_authorization(:index) }
    end

    context 'as a lecturer' do
      let(:account) { FactoryBot.create(:account) }
      let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: account, term: term) }

      it { is_expected.not_to permit_authorization(:index) }
    end

    context 'as a tutor' do
      let(:account) { FactoryBot.create(:account) }
      let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, account: account, term: term) }

      it { is_expected.not_to permit_authorization(:index) }
    end

    context 'as a student' do
      let(:account) { FactoryBot.create(:account) }
      let!(:term_registration) { FactoryBot.create(:term_registration, :student, account: account, term: term) }

      it { is_expected.not_to permit_authorization(:index) }
    end
  end
end
