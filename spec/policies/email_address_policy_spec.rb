require 'rails_helper'

RSpec.describe EmailAddressPolicy do
  let(:account) { FactoryBot.create(:account) }
  let(:email_address) { FactoryBot.create(:email_address, account: account) }

  context 'as an admin' do
    let(:current_account) { FactoryBot.create(:account, :admin) }

    describe 'collections' do
      subject { described_class.new(current_account, described_class.policy_record_with(account: account)) }

      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      subject { described_class.new(current_account, email_address) }

      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
      it { is_expected.to permit_authorization(:destroy) }
    end
  end

  context 'as an arbirary user' do
    let(:current_account) { FactoryBot.create(:account) }

    describe 'collections' do
      subject { described_class.new(current_account, described_class.policy_record_with(account: account)) }

      describe 'own email addresses' do
        let(:account) { current_account }

        it { is_expected.to permit_authorization(:index) }
      end

      describe 'someone else\'s email addresses' do
        it { is_expected.not_to permit_authorization(:index) }
      end
    end

    describe 'members' do
      subject { described_class.new(current_account, email_address) }

      context 'own email address' do
        let(:account) { current_account }

        it { is_expected.not_to permit_authorization(:new) }
        it { is_expected.not_to permit_authorization(:create) }
        it { is_expected.not_to permit_authorization(:edit) }
        it { is_expected.not_to permit_authorization(:update) }
        it { is_expected.not_to permit_authorization(:destroy) }
      end

      context 'someone else\'s email address' do
        it { is_expected.not_to permit_authorization(:new) }
        it { is_expected.not_to permit_authorization(:create) }
        it { is_expected.not_to permit_authorization(:edit) }
        it { is_expected.not_to permit_authorization(:update) }
        it { is_expected.not_to permit_authorization(:destroy) }
      end
    end
  end
end
