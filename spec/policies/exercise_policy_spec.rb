require 'rails_helper'

describe ExercisePolicy do
  let(:term) { FactoryBot.create(:term) }
  let(:exercise) { FactoryBot.create(:exercise, term: term) }

  context 'for index' do
    subject { ExercisePolicy.new(user, ExercisePolicy.term_policy_record(term)) }

    context 'as an admin' do
      let(:user) { FactoryBot.create(:account, :admin) }

      it { is_expected.to permit_authorization :index }
    end

    context 'as a lecturer' do
      let(:user) { FactoryBot.create(:account, :lecturer) }
      let(:term) { user.term_registrations.lecturers.first.term }

      it { is_expected.to permit_authorization :index }
    end

    context 'as a tutor' do
      let(:user) { FactoryBot.create(:account, :tutor) }
      let(:term) {  user.term_registrations.tutors.first.term }

      it { is_expected.to permit_authorization :index }
    end

    context 'as a student' do
      let(:user) { FactoryBot.create(:account, :student) }
      let(:term) { user.term_registrations.students.first.term }

      it { is_expected.to permit_authorization :index }
    end
  end

  context 'members' do
    subject { Pundit.policy(user, exercise) }

    context 'as an admin' do
      let(:user) { FactoryBot.create(:account, :admin) }
      let(:exercise) { FactoryBot.create(:exercise, term: term) }

      it { is_expected.to permit_authorization :show }
      it { is_expected.to permit_authorization :new }
      it { is_expected.to permit_authorization :create }
      it { is_expected.to permit_authorization :edit }
      it { is_expected.to permit_authorization :update }
      it { is_expected.to permit_authorization :destroy }
    end

    context 'as a lecturer' do
      let(:user) { FactoryBot.create(:account, :lecturer) }
      let(:term) { user.term_registrations.lecturers.first.term }

      it { is_expected.to permit_authorization :show }
      it { is_expected.to permit_authorization :new }
      it { is_expected.to permit_authorization :create }
      it { is_expected.to permit_authorization :edit }
      it { is_expected.to permit_authorization :update }
      it { is_expected.to permit_authorization :destroy }
    end

    context 'as a tutor' do
      let(:user) { FactoryBot.create(:account, :tutor) }
      let(:term) { user.term_registrations.tutors.first.term }

      it { is_expected.to permit_authorization :show }
      it { is_expected.not_to permit_authorization :new }
      it { is_expected.not_to permit_authorization :create }
      it { is_expected.not_to permit_authorization :edit }
      it { is_expected.not_to permit_authorization :update }
      it { is_expected.not_to permit_authorization :destroy }
    end

    context 'as a student' do
      let(:user) { FactoryBot.create(:account, :student) }
      let(:term) { user.term_registrations.students.first.term }

      it { is_expected.to permit_authorization :show }
      it { is_expected.not_to permit_authorization :new }
      it { is_expected.not_to permit_authorization :create }
      it { is_expected.not_to permit_authorization :edit }
      it { is_expected.not_to permit_authorization :update }
      it { is_expected.not_to permit_authorization :destroy }
    end
  end
end
