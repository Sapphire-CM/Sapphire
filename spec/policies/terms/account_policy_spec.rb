require 'rails_helper'

RSpec.describe Terms::AccountPolicy do
  subject { described_class.new(account, record) }

  let(:term) { FactoryBot.create(:term) }
  let(:term_registration_to_view) { FactoryBot.create(:term_registration, :student, term: term) }

  shared_examples "full permissions" do
    describe 'collections' do
      let(:record) { described_class.term_policy_record(term) }

      it { is_expected.to permit_authorization(:index) }
    end
  end

  shared_examples "no permissions" do
    describe 'collections' do
      let(:record) { described_class.term_policy_record(term) }

      it { is_expected.not_to permit_authorization(:index) }
    end
  end

  context 'as an admin' do
    let(:account) { FactoryBot.create(:account, :admin) }

    it_behaves_like "full permissions"
  end

  context 'as a lecturer' do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, term: term, account: account) }

    it_behaves_like "full permissions"
  end

  context 'as a tutor' do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, term: term, account: account) }

    it_behaves_like "no permissions"
  end

  context 'as a student' do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, account: account) }

    it_behaves_like "no permissions"
  end

end
