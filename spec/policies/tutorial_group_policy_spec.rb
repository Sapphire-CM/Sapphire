require 'rails_helper'

RSpec.describe TutorialGroupPolicy do
  let(:term) { FactoryBot.create(:term) }
  let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }

  context 'admin permissions' do
    shared_examples 'admin member permissions' do
      describe 'collections' do
        subject { described_class.new(account, described_class.term_policy_record(term)) }

        it { is_expected.to permit_authorization(:index) }
        it { is_expected.to permit_authorization(:points_overview) }
      end

      describe 'members' do
        subject { described_class.new(account, tutorial_group) }

        it { is_expected.to permit_authorization(:show) }
        it { is_expected.to permit_authorization(:new) }
        it { is_expected.to permit_authorization(:create) }
        it { is_expected.to permit_authorization(:edit) }
        it { is_expected.to permit_authorization(:update) }
        it { is_expected.to permit_authorization(:destroy) }
      end
    end

    context 'as an admin' do
      let(:account) { FactoryBot.create(:account, :admin) }

      it_behaves_like 'admin member permissions'
    end

    context 'as a lecturer' do
      let(:account) { FactoryBot.create(:account) }
      let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, term: term, account: account) }

      it_behaves_like 'admin member permissions'
    end
  end


  context 'as a tutor' do
    let(:account) { FactoryBot.create(:account) }
    let(:another_tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, term: term, account: account, tutorial_group: another_tutorial_group) }

    describe 'collections' do
      subject { described_class.new(account, described_class.term_policy_record(term)) }

      it { is_expected.to permit_authorization(:index) }
      it { is_expected.to permit_authorization(:points_overview) }
    end

    describe 'members' do
      subject { described_class.new(account, tutorial_group) }

      it { is_expected.to permit_authorization(:show) }
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:edit) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
    end
  end

  context 'as a student' do
    let(:account) { FactoryBot.create(:account) }
    let(:another_tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, account: account, tutorial_group: another_tutorial_group) }

    describe 'collections' do
      subject { described_class.new(account, described_class.term_policy_record(term)) }

      it { is_expected.not_to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:points_overview) }
    end

    describe 'members' do
      subject { described_class.new(account, tutorial_group) }

      it { is_expected.not_to permit_authorization(:show) }
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:edit) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
    end
  end
end
