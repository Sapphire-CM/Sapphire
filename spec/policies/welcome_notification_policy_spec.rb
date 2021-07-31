require 'rails_helper'

RSpec.describe WelcomeNotificationPolicy do
  subject { described_class.new(account, record) }

  let(:term) { FactoryBot.create(:term) }
  let(:record) { described_class.term_policy_record(term) }

  context 'as an admin' do
    let(:account) { FactoryBot.create(:account, :admin) }

    describe 'members' do
      it { is_expected.to permit_authorization(:create) }
    end
  end


  context "as a lecturer" do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, term: term, account: account) }

    describe 'members' do
      it { is_expected.to permit_authorization(:create) }
    end
  end

  context "as a tutor" do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, term: term, account: account) }

    describe 'members' do
      it { is_expected.not_to permit_authorization(:create) }
    end
  end

  context 'as a student' do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, account: account) }

    describe 'members' do
      it { is_expected.not_to permit_authorization(:create) }
    end
  end
end
