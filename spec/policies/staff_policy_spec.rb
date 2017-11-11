require 'rails_helper'

RSpec.describe StaffPolicy do
  let(:term) { FactoryGirl.create(:term) }

  subject { described_class.new(account, described_class.term_policy_record(term)) }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    it { is_expected.to permit_authorization(:index) }
    it { is_expected.to permit_authorization(:search) }
  end

  context 'as a lecturer' do
    let(:account) { FactoryGirl.create(:account) }

    describe 'in lectured term' do
      let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, account: account, term: term) }

      it { is_expected.to permit_authorization(:index) }
      it { is_expected.to permit_authorization(:search) }
    end

    describe 'in another term' do
      let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, account: account) }

      it { is_expected.not_to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:search) }
    end
  end

  context 'as a tutor' do
    let(:account) { FactoryGirl.create(:account) }

    describe 'tutored term' do
      let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, account: account, term: term) }

      it { is_expected.to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:search) }
    end

    describe 'another term' do
      let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, account: account) }

      it { is_expected.not_to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:search) }
    end
  end

  context 'as a student' do
    let(:account) { FactoryGirl.create(:account) }

    describe 'attended term' do
      let!(:term_registration) { FactoryGirl.create(:term_registration, :student, account: account, term: term) }

      it { is_expected.not_to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:search) }
    end

    describe 'another term' do
      let!(:term_registration) { FactoryGirl.create(:term_registration, :student, account: account) }

      it { is_expected.not_to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:search) }
    end
  end
end
