require 'rails_helper'

RSpec.describe StudentsPolicy do
  subject { described_class.new(account, described_class.term_policy_record(term)) }

  let(:term) { FactoryBot.create(:term) }

  context 'admins' do
    let(:account) { FactoryBot.create(:account, :admin) }

    describe 'collections' do
      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      it { is_expected.to permit_authorization(:show) }
    end
  end

  context 'lecturers' do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: account, term: term) }

    describe 'collections' do
      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      it { is_expected.to permit_authorization(:show) }
    end
  end

  context 'tutors' do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, account: account, term: term) }

    describe 'collections' do
      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      it { is_expected.to permit_authorization(:show) }
    end
  end

  context 'students' do
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, account: account, term: term) }

    describe 'collections' do
      it { is_expected.not_to permit_authorization(:index) }
    end

    describe 'members' do
      it { is_expected.not_to permit_authorization(:show) }
    end
  end
end
