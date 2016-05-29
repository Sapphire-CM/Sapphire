require 'rails_helper'

RSpec.describe TermRegistrationPolicy do
  subject { described_class.new(account, term_registration) }
  let(:term_registration) { FactoryGirl.create(:term_registration) }
  let(:term) { term_registration.term }

  context 'as a admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    describe 'members' do
      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:destroy) }
    end
  end

  context 'as a lecturer' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:lecturer_term_registration) { FactoryGirl.create(:term_registration, :lecturer, account: account, term: term) }

    describe 'members' do
      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:destroy) }
    end
  end

  context 'as a tutor' do
    let(:account) { FactoryGirl.create(:account) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let!(:tutor_term_registration) { FactoryGirl.create(:term_registration, :tutor, account: account, term: term, tutorial_group: tutorial_group) }

    describe 'members' do
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:destroy) }
    end
  end

  context 'as a student' do
    let(:account) { FactoryGirl.create(:account) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let!(:student_term_registration) { FactoryGirl.create(:term_registration, :student, account: account, term: term, tutorial_group: tutorial_group) }

    describe 'members' do
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:destroy) }
    end
  end


end
