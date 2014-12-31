require 'rails_helper'

describe GradingScalePolicy do
  subject { Pundit.policy(user, GradingScalePolicy.with(record)) }

  context 'as an admin' do
    let(:user) { FactoryGirl.create(:account, :admin) }
    let(:record) { FactoryGirl.create(:term) }

    it { is_expected.to permit_authorization :edit }
    it { is_expected.to permit_authorization :update }
  end

  context 'as a lecturer' do
    let(:user) { FactoryGirl.create(:account, :lecturer) }
    let(:record) { user.term_registrations.lecturers.first.term }

    it { is_expected.to permit_authorization :edit }
    it { is_expected.to permit_authorization :update }
  end

  context 'as a tutor' do
    let(:user) { FactoryGirl.create(:account, :tutor) }
    let(:record) { user.term_registrations.tutors.first.term }

    it { is_expected.not_to permit_authorization :edit }
    it { is_expected.not_to permit_authorization :update }
  end

  context 'as a student' do
    let(:user) { FactoryGirl.create(:account, :student) }
    let(:record) { user.term_registrations.students.first.term }

    it { is_expected.not_to permit_authorization :edit }
    it { is_expected.not_to permit_authorization :update }
  end
end
