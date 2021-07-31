require 'rails_helper'

RSpec.describe ServicePolicy do
  let(:exercise) { FactoryBot.create(:exercise, term: term) }
  let(:service) { FactoryBot.create(:service, exercise: exercise) }
  let(:term) { FactoryBot.create(:term) }

  context 'as an admin' do
    let(:account) { FactoryBot.create(:account, :admin) }

    describe 'collections' do
      let(:policy_record) { described_class.term_policy_record(term) }
      subject { described_class.new(account, policy_record) }

      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      subject { described_class.new(account, service) }

      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
    end
  end

  context 'as a lecturer' do
    let(:account) { FactoryBot.create(:account) }

    context 'of a lectured term' do
      let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, term: term, account: account) }

      describe 'collections' do
        let(:policy_record) { described_class.term_policy_record(term) }

        subject { described_class.new(account, policy_record) }

        it { is_expected.to permit_authorization(:index) }
      end

      describe 'members' do
        subject { described_class.new(account, service) }

        it { is_expected.to permit_authorization(:edit) }
        it { is_expected.to permit_authorization(:update) }
      end
    end

    context 'of another term' do
      let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: account) }

      describe 'collections' do
        let(:policy_record) { described_class.term_policy_record(term) }

        subject { described_class.new(account, policy_record) }

        it { is_expected.not_to permit_authorization(:index) }
      end

      describe 'members' do
        subject { described_class.new(account, service) }

        it { is_expected.not_to permit_authorization(:edit) }
        it { is_expected.not_to permit_authorization(:update) }
      end
    end
  end

  %I(tutor student).each do |role|
    context "as a #{role}" do
      let(:account) { FactoryBot.create(:account) }

      context 'of attended term' do
        let!(:term_registration) { FactoryBot.create(:term_registration, role, account: account, term: term) }

        describe 'collections' do
          let(:policy_record) { described_class.term_policy_record(term) }

          subject { described_class.new(account, policy_record) }

          it { is_expected.not_to permit_authorization(:index) }
        end

        describe 'members' do
          subject { described_class.new(account, service) }

          it { is_expected.not_to permit_authorization(:edit) }
          it { is_expected.not_to permit_authorization(:update) }
        end
      end

      context 'of another term' do
        let!(:term_registration) { FactoryBot.create(:term_registration, role, account: account) }

        describe 'collections' do
          let(:policy_record) { described_class.term_policy_record(term) }

          subject { described_class.new(account, policy_record) }

          it { is_expected.not_to permit_authorization(:index) }
        end

        describe 'members' do
          subject { described_class.new(account, service) }

          it { is_expected.not_to permit_authorization(:edit) }
          it { is_expected.not_to permit_authorization(:update) }
        end
      end
    end
  end
end
