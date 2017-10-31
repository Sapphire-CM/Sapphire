require 'rails_helper'

RSpec.describe StudentGroupPolicy do
  let(:term) { tutorial_group.term }
  let(:tutorial_group) { FactoryGirl.create(:tutorial_group) }
  let(:student_group) { FactoryGirl.create(:student_group, tutorial_group: tutorial_group) }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    context 'collections' do
      subject { described_class.new(account, term) }

      it { is_expected.to permit_authorization(:index) }
      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
    end

    context 'members' do
      subject { described_class.new(account, student_group) }

      it { is_expected.to permit_authorization(:show) }
      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
      it { is_expected.to permit_authorization(:destroy) }
    end
  end

  context 'as a lecturer' do
    let(:account) { FactoryGirl.create(:account) }
    before :each do
      FactoryGirl.create(:term_registration, :lecturer, term: term, account: account)
    end

    context 'collections' do
      subject { described_class.new(account, term) }

      it { is_expected.to permit_authorization(:index) }
      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
    end

    context 'members' do
      subject { described_class.new(account, student_group) }

      it { is_expected.to permit_authorization(:show) }

      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
      it { is_expected.to permit_authorization(:destroy) }
    end
  end

  context 'as a tutor' do
    let(:account) { FactoryGirl.create(:account) }
    let(:another_tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }

    before :each do
      FactoryGirl.create(:term_registration, :tutor, term: term, account: account, tutorial_group: another_tutorial_group)
    end

    context 'collections' do
      subject { described_class.new(account, term) }

      it { is_expected.to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
    end

    context 'members' do
      subject { described_class.new(account, student_group) }

      it { is_expected.to permit_authorization(:show) }
      it { is_expected.not_to permit_authorization(:edit) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
    end
  end

  context 'as a student' do
    let(:account) { FactoryGirl.create(:account) }
    let(:another_tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }

    before :each do
      FactoryGirl.create(:term_registration, :student, term: term, account: account, tutorial_group: another_tutorial_group)
    end

    context 'collections' do
      subject { described_class.new(account, tutorial_group) }

      it { is_expected.not_to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
    end

    context 'members' do
      subject { described_class.new(account, student_group) }

      it { is_expected.not_to permit_authorization(:show) }
      it { is_expected.not_to permit_authorization(:edit) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
    end
  end
end
