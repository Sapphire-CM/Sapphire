require 'rails_helper'

RSpec.describe TutorialGroupPolicy do
  let(:term) { FactoryGirl.create(:term) }
  let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }

  context 'admin permissions' do
    shared_examples 'admin member permissions' do
      describe 'collections' do
        subject { described_class.new(account, term) }

        it { is_expected.to permit_authorization(:index) }
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
      let(:account) { FactoryGirl.create(:account, :admin) }

      it_behaves_like 'admin member permissions'
    end

    context 'as a lecturer' do
      let(:account) { FactoryGirl.create(:account) }
      let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term, account: account) }

      it_behaves_like 'admin member permissions'
    end
  end


  context 'as a tutor' do
    let(:account) { FactoryGirl.create(:account) }
    let(:another_tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, account: account, tutorial_group: another_tutorial_group) }

    describe 'collections' do
      subject { described_class.new(account, term) }

      it { is_expected.to permit_authorization(:index) }
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
    let(:account) { FactoryGirl.create(:account) }
    let(:another_tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :student, term: term, account: account, tutorial_group: another_tutorial_group) }

    describe 'collections' do
      subject { described_class.new(account, term) }

      it { is_expected.not_to permit_authorization(:index) }
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
