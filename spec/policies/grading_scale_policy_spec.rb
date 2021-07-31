require 'rails_helper'

describe GradingScalePolicy do

  context 'for index' do
    subject { Pundit.policy(user, GradingScalePolicy.term_policy_record(term)) }

    context 'as an admin' do
      let(:user) { FactoryBot.create(:account, :admin) }
      let(:term) { FactoryBot.create(:term) }

      it { is_expected.to permit_authorization :index }
    end

    context 'as a lecturer' do
      let(:user) { FactoryBot.create(:account, :lecturer) }
      let(:term) { user.term_registrations.lecturers.first.term }

      it { is_expected.to permit_authorization :index }
    end

    context 'as a tutor' do
      let(:user) { FactoryBot.create(:account, :tutor) }
      let(:term) { user.term_registrations.tutors.first.term }

      it { is_expected.not_to permit_authorization :index }
    end

    context 'as a student' do
      let(:user) { FactoryBot.create(:account, :student) }
      let(:term) { user.term_registrations.students.first.term }

      it { is_expected.not_to permit_authorization :index }
    end
  end

  context 'members' do
    subject { Pundit.policy(user, grading_scale) }

    let(:grading_scale) { term.grading_scales.first }

    context 'as an admin' do
      let(:user) { FactoryBot.create(:account, :admin) }
      let(:term) { FactoryBot.create(:term) }

      it { is_expected.to permit_authorization :update }
    end

    context 'as a lecturer' do
      let(:user) { FactoryBot.create(:account, :lecturer) }
      let(:term) { user.term_registrations.lecturers.first.term }

      it { is_expected.to permit_authorization :update }
    end

    context 'as a tutor' do
      let(:user) { FactoryBot.create(:account, :tutor) }
      let(:term) { user.term_registrations.tutors.first.term }

      it { is_expected.not_to permit_authorization :update }
    end

    context 'as a student' do
      let(:user) { FactoryBot.create(:account, :student) }
      let(:term) { user.term_registrations.students.first.term }

      it { is_expected.not_to permit_authorization :update }
    end
  end

end
