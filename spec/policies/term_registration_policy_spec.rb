require 'rails_helper'

RSpec.describe TermRegistrationPolicy do
  subject { described_class.new(account, term_registration) }

  let(:term) { FactoryGirl.create(:term) }
  let(:term_registration) { FactoryGirl.create(:term_registration, term: term) }

  shared_examples "administration permissions" do
    describe 'members' do
      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:show) }
      it { is_expected.to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
      it { is_expected.to permit_authorization(:destroy) }
    end
  end

  shared_examples "no administration permissions" do
    describe 'members' do
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:edit) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
    end
  end

  shared_examples "read permissions" do
    describe 'members' do
      it { is_expected.to permit_authorization(:show) }
    end
  end

  shared_examples "no read permissions" do
    describe 'members' do
      it { is_expected.not_to permit_authorization(:show) }
    end
  end

  context 'as a admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    it_behaves_like "read permissions"
    it_behaves_like "administration permissions"

  end

  context 'as a lecturer' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:lecturer_term_registration) { FactoryGirl.create(:term_registration, :lecturer, account: account, term: term) }

    it_behaves_like "read permissions"
    it_behaves_like "administration permissions"
  end

  context 'as a tutor' do
    let(:account) { FactoryGirl.create(:account) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let!(:tutor_term_registration) { FactoryGirl.create(:term_registration, :tutor, account: account, term: term, tutorial_group: tutorial_group) }

    it_behaves_like "read permissions"
    it_behaves_like "no administration permissions"
  end

  context 'as a student' do
    let(:account) { FactoryGirl.create(:account) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let!(:student_term_registration) { FactoryGirl.create(:term_registration, :student, account: account, term: term, tutorial_group: tutorial_group) }

    it_behaves_like "no administration permissions"
    it_behaves_like "no read permissions"
  end
end
