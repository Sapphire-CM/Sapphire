require 'rails_helper'

RSpec.describe ExportPolicy do
  let(:term) { FactoryBot.create(:term) }
  let(:export) { FactoryBot.create(:export, term: term) }

  context 'as an admin' do
    let(:account) { FactoryBot.create(:account, :admin) }


    describe 'collections and creation' do
      subject { described_class.new(account, described_class.term_policy_record(term)) }

      it { is_expected.to permit_authorization(:index) }
      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
    end

    describe 'members' do
      subject { described_class.new(account, term) }

      it { is_expected.to permit_authorization(:show) }
      it { is_expected.to permit_authorization(:download) }
      it { is_expected.to permit_authorization(:destroy) }
    end
  end

  context 'as a lecturer' do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, term: current_term, account: account) }

    describe 'of the given term' do
      let(:current_term) { term }

      describe 'collections and creation' do
        subject { described_class.new(account, described_class.term_policy_record(term)) }

        it { is_expected.to permit_authorization(:index) }
        it { is_expected.to permit_authorization(:new) }
        it { is_expected.to permit_authorization(:create) }
      end

      describe 'members' do
        subject { described_class.new(account, export) }

        it { is_expected.to permit_authorization(:show) }
        it { is_expected.to permit_authorization(:download) }
        it { is_expected.to permit_authorization(:destroy) }
      end
    end

    describe 'of another term' do
      let(:current_term) { FactoryBot.create(:term, course: term.course) }

      describe 'collections and creation' do
        subject { described_class.new(account, described_class.term_policy_record(term)) }

        it { is_expected.not_to permit_authorization(:index) }
        it { is_expected.not_to permit_authorization(:new) }
        it { is_expected.not_to permit_authorization(:create) }
      end

      describe 'members' do
        subject { described_class.new(account, export) }

        it { is_expected.not_to permit_authorization(:show) }
        it { is_expected.not_to permit_authorization(:download) }
        it { is_expected.not_to permit_authorization(:destroy) }
      end
    end
  end

  %I(tutor student).each do |role|
    context "as a #{role}" do
      let(:account) { FactoryBot.create(:account) }
      let!(:term_registration) { FactoryBot.create(:term_registration, role, term: current_term, account: account) }

      describe 'of the given term' do
        let(:current_term) { term }

        describe 'collections and creation' do
          subject { described_class.new(account, described_class.term_policy_record(current_term)) }

          it { is_expected.not_to permit_authorization(:index) }
          it { is_expected.not_to permit_authorization(:new) }
          it { is_expected.not_to permit_authorization(:create) }
        end

        describe 'members' do
          subject { described_class.new(account, export) }

          it { is_expected.not_to permit_authorization(:show) }
          it { is_expected.not_to permit_authorization(:download) }
          it { is_expected.not_to permit_authorization(:destroy) }
        end
      end

      describe 'of another term' do
        let(:current_term) { FactoryBot.create(:term, course: term.course) }

        describe 'collections and creation' do
          subject { described_class.new(account, described_class.term_policy_record(current_term)) }

          it { is_expected.not_to permit_authorization(:index) }
          it { is_expected.not_to permit_authorization(:new) }
          it { is_expected.not_to permit_authorization(:create) }
        end

        describe 'members' do
          subject { described_class.new(account, export) }

          it { is_expected.not_to permit_authorization(:show) }
          it { is_expected.not_to permit_authorization(:download) }
          it { is_expected.not_to permit_authorization(:destroy) }
        end
      end
    end
  end
end
