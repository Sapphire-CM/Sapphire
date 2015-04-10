require 'rails_helper'

RSpec.describe ExportPolicy do
  let(:term) { FactoryGirl.create(:term) }
  let(:export) { FactoryGirl.create(:export, term: term) }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    subject { ExportPolicy.new(account, term) }

    it { is_expected.to permit_authorization(:index) }
    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:new) }
    it { is_expected.to permit_authorization(:create) }
    it { is_expected.to permit_authorization(:download) }
    it { is_expected.to permit_authorization(:destroy) }
  end

  context 'as a lecturer' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: current_term, account: account) }

    describe 'of the given term' do
      let(:current_term) { term }

      describe 'collections and creation' do
        subject { ExportPolicy.new(account, term) }

        it { is_expected.to permit_authorization(:index) }
        it { is_expected.to permit_authorization(:new) }
        it { is_expected.to permit_authorization(:create) }
      end

      describe 'members' do
        subject { ExportPolicy.new(account, export) }

        it { is_expected.to permit_authorization(:show) }
        it { is_expected.to permit_authorization(:download) }
        it { is_expected.to permit_authorization(:destroy) }
      end
    end

    describe 'of another term' do
      let(:current_term) { FactoryGirl.create(:term, course: term.course) }

      describe 'collections and creation' do
        subject { ExportPolicy.new(account, term) }

        it { is_expected.not_to permit_authorization(:index) }
        it { is_expected.not_to permit_authorization(:new) }
        it { is_expected.not_to permit_authorization(:create) }
      end

      describe 'members' do
        subject { ExportPolicy.new(account, export) }

        it { is_expected.not_to permit_authorization(:show) }
        it { is_expected.not_to permit_authorization(:download) }
        it { is_expected.not_to permit_authorization(:destroy) }
      end
    end
  end

  %I(tutor student).each do |role|
    context "as a #{role}" do
      let(:account) { FactoryGirl.create(:account) }
      let!(:term_registration) { FactoryGirl.create(:term_registration, role, term: current_term, account: account) }

      describe 'of the given term' do
        let(:current_term) { term }

        describe 'collections and creation' do
          subject { ExportPolicy.new(account, term) }

          it { is_expected.not_to permit_authorization(:index) }
          it { is_expected.not_to permit_authorization(:new) }
          it { is_expected.not_to permit_authorization(:create) }
        end

        describe 'members' do
          subject { ExportPolicy.new(account, export) }

          it { is_expected.not_to permit_authorization(:show) }
          it { is_expected.not_to permit_authorization(:download) }
          it { is_expected.not_to permit_authorization(:destroy) }
        end
      end

      describe 'of another term' do
        let(:current_term) { FactoryGirl.create(:term, course: term.course) }

        describe 'collections and creation' do
          subject { ExportPolicy.new(account, term) }

          it { is_expected.not_to permit_authorization(:index) }
          it { is_expected.not_to permit_authorization(:new) }
          it { is_expected.not_to permit_authorization(:create) }
        end

        describe 'members' do
          subject { ExportPolicy.new(account, export) }

          it { is_expected.not_to permit_authorization(:show) }
          it { is_expected.not_to permit_authorization(:download) }
          it { is_expected.not_to permit_authorization(:destroy) }
        end
      end
    end
  end
end
