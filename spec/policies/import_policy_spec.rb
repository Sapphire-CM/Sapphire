require 'rails_helper'

RSpec.describe ImportPolicy do
  let(:import) { FactoryGirl.create(:import) }
  let(:term) { import.term }

  subject { ImportPolicy.new(account, import) }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:new) }
    it { is_expected.to permit_authorization(:create) }
    it { is_expected.to permit_authorization(:edit) }
    it { is_expected.to permit_authorization(:update) }
    it { is_expected.to permit_authorization(:destroy) }
    it { is_expected.to permit_authorization(:full_mapping_table) }
    it { is_expected.to permit_authorization(:results) }
  end

  context 'as a lecturer' do
    let(:account) { FactoryGirl.create(:account) }

    describe 'of the current term' do
      let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term, account: account) }

      it { is_expected.to permit_authorization(:show) }
      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
      it { is_expected.to permit_authorization(:destroy) }
      it { is_expected.to permit_authorization(:full_mapping_table) }
      it { is_expected.to permit_authorization(:results) }
    end

    describe 'of another term' do
      let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, account: account) }

      it { is_expected.not_to permit_authorization(:show) }
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:edit) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
      it { is_expected.not_to permit_authorization(:full_mapping_table) }
      it { is_expected.not_to permit_authorization(:results) }
    end
  end

  %I(tutor student).each do |role|
    context "as a #{role}" do
      let(:account) { FactoryGirl.create(:account) }

      describe 'of the current term' do
        let!(:term_registration) { FactoryGirl.create(:term_registration, role, term: term, account: account) }

        it { is_expected.not_to permit_authorization(:show) }
        it { is_expected.not_to permit_authorization(:new) }
        it { is_expected.not_to permit_authorization(:create) }
        it { is_expected.not_to permit_authorization(:edit) }
        it { is_expected.not_to permit_authorization(:update) }
        it { is_expected.not_to permit_authorization(:destroy) }
        it { is_expected.not_to permit_authorization(:full_mapping_table) }
        it { is_expected.not_to permit_authorization(:results) }
      end

      describe 'of another term' do
        let!(:term_registration) { FactoryGirl.create(:term_registration, role, account: account) }

        it { is_expected.not_to permit_authorization(:show) }
        it { is_expected.not_to permit_authorization(:new) }
        it { is_expected.not_to permit_authorization(:create) }
        it { is_expected.not_to permit_authorization(:edit) }
        it { is_expected.not_to permit_authorization(:update) }
        it { is_expected.not_to permit_authorization(:destroy) }
        it { is_expected.not_to permit_authorization(:full_mapping_table) }
        it { is_expected.not_to permit_authorization(:results) }
      end
    end
  end
end
