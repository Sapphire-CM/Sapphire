require 'rails_helper'

RSpec.describe CommentPolicy do
  subject { described_class.new(account) }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    it { is_expected.to permit_authorization(:index) }
    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:edit) }
    it { is_expected.to permit_authorization(:update) }
    it { is_expected.to permit_authorization(:destroy) }
    it { is_expected.to permit_authorization(:create) }
  end

  context 'as a lecturer' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, account: account, term: term) }

    it { is_expected.to permit_authorization(:index) }
    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:edit) }
    it { is_expected.to permit_authorization(:update) }
    it { is_expected.to permit_authorization(:destroy) }
    it { is_expected.to permit_authorization(:create) }
  end

  context 'as a tutor' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, account: account, term: term) }

    it { is_expected.to permit_authorization(:index) }
    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:edit) }
    it { is_expected.to permit_authorization(:update) }
    it { is_expected.to permit_authorization(:destroy) }
    it { is_expected.to permit_authorization(:create) }
  end

  context 'as a student' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :student, account: account, term: term) }

    it { is_expected.not_to permit_authorization(:index) }
    it { is_expected.not_to permit_authorization(:show) }
    it { is_expected.not_to permit_authorization(:edit) }
    it { is_expected.not_to permit_authorization(:update) }
    it { is_expected.not_to permit_authorization(:destroy) }
    it { is_expected.not_to permit_authorization(:create) }
  end
end
