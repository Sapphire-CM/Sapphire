require 'rails_helper'

RSpec.describe StudentGroupPolicy do
  let(:term) { tutorial_group.term }
  let(:tutorial_group) { FactoryBot.create(:tutorial_group) }
  let(:student_group) { FactoryBot.create(:student_group, tutorial_group: tutorial_group) }

  context 'as an admin' do
    let(:account) { FactoryBot.create(:account, :admin) }

    context 'collections' do
      subject { described_class.new(account, described_class.term_policy_record(term)) }

      it { is_expected.to permit_authorization(:index) }
      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:search_students) }
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
    let(:account) { FactoryBot.create(:account) }
    before :each do
      FactoryBot.create(:term_registration, :lecturer, term: term, account: account)
    end

    context 'collections' do
      subject { described_class.new(account, described_class.term_policy_record(term)) }

      it { is_expected.to permit_authorization(:index) }
      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:search_students) }
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
    let(:account) { FactoryBot.create(:account) }
    let(:another_tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }

    before :each do
      FactoryBot.create(:term_registration, :tutor, term: term, account: account, tutorial_group: another_tutorial_group)
    end

    context 'collections' do
      subject { described_class.new(account, described_class.term_policy_record(term)) }

      it { is_expected.to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:search_students) }
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
    let(:account) { FactoryBot.create(:account) }
    let(:another_tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }

    before :each do
      FactoryBot.create(:term_registration, :student, term: term, account: account, tutorial_group: another_tutorial_group)
    end

    context 'collections' do
      subject { described_class.new(account, described_class.term_policy_record(term)) }

      it { is_expected.not_to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:search_students) }
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
