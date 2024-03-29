require "rails_helper"

RSpec.describe ImpersonationPolicy do
  subject { described_class.new(account, impersonation) }
  let(:impersonation) { Impersonation.new(impersonatable: account_to_impersonate) }
  let(:account_to_impersonate) { FactoryBot.create(:account) }

  context 'as an admin' do
    let(:account) { FactoryBot.create(:account, :admin) }

    context 'other account' do
      it { is_expected.to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:destroy) }
    end

    context 'self' do
      let(:account_to_impersonate) { account }

      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:destroy) }
    end
  end

  context 'as a lecturer' do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: account) }

    it { is_expected.not_to permit_authorization(:create) }
    it { is_expected.to permit_authorization(:destroy) }
  end

  context 'as a tutor' do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, account: account) }

    it { is_expected.not_to permit_authorization(:create) }
    it { is_expected.to permit_authorization(:destroy) }
  end

  context 'as a student' do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, account: account) }

    it { is_expected.not_to permit_authorization(:create) }
    it { is_expected.to permit_authorization(:destroy) }
  end
end
