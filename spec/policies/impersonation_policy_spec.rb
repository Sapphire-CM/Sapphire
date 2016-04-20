require "rails_helper"

RSpec.describe ImpersonationPolicy do
  subject { described_class.new(account, impersonation) }
  let(:impersonation) { Impersonation.new }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    it { is_expected.to permit_authorization(:create) }
    it { is_expected.to permit_authorization(:destroy) }
  end

  context 'as a lecturer' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, account: account) }

    it { is_expected.not_to permit_authorization(:create) }
    it { is_expected.to permit_authorization(:destroy) }
  end

  context 'as a tutor' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, account: account) }

    it { is_expected.not_to permit_authorization(:create) }
    it { is_expected.to permit_authorization(:destroy) }
  end

  context 'as a student' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :student, account: account) }

    it { is_expected.not_to permit_authorization(:create) }
    it { is_expected.to permit_authorization(:destroy) }
  end
end
