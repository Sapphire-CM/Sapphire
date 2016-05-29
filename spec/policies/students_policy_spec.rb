require 'rails_helper'

RSpec.describe StudentsPolicy do
  subject { described_class.new(account, term) }

  let(:term) { FactoryGirl.create(:term) }

  context 'admins' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    describe 'collections' do
      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      it { is_expected.to permit_authorization(:show) }
    end
  end

  context 'lecturers' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, account: account, term: term) }

    describe 'collections' do
      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      it { is_expected.to permit_authorization(:show) }
    end
  end

  context 'tutors' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, account: account, term: term) }

    describe 'collections' do
      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      it { is_expected.to permit_authorization(:show) }
    end
  end

  context 'students' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :student, account: account, term: term) }

    describe 'collections' do
      it { is_expected.not_to permit_authorization(:index) }
    end

    describe 'members' do
      it { is_expected.not_to permit_authorization(:show) }
    end
  end
end
