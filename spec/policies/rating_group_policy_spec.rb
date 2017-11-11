require 'rails_helper'

RSpec.describe RatingGroupPolicy do
  describe 'resolving through Pundit' do
    let(:user) { create(:account, :admin) }
    let(:rating_group) { create(:rating_group) }

    it 'returns a RatingGroupPolicy' do
      expect(Pundit.policy(user, rating_group)).to be_a(RatingGroupPolicy)
    end
  end

  describe '#index?' do
    subject { RatingGroupPolicy.new(user, policy_record) }

    let(:policy_record) { described_class.term_policy_record(term) }

    context 'as an admin' do
      let(:user) { create(:account, :admin) }
      let(:term) { create(:term) }

      it { is_expected.to permit_authorization :index }
    end

    context 'as lecturer' do
      let(:user) { FactoryGirl.create(:account, :lecturer) }
      let(:term) { user.term_registrations.lecturers.first.term }

      it { is_expected.to permit_authorization :index }
    end

    context 'as tutor' do
      let(:user) { FactoryGirl.create(:account, :tutor) }
      let(:term) { user.term_registrations.tutors.first.term }

      it { is_expected.not_to permit_authorization :index }
    end

    context 'as student' do
      let(:user) { FactoryGirl.create(:account, :student) }
      let(:term) { user.term_registrations.students.first.term }

      it { is_expected.not_to permit_authorization :index }
    end
  end

  describe 'further actions' do
    subject { RatingGroupPolicy.new(user, rating_group) }

    let(:exercise) { create(:exercise, term: term) }
    let(:rating_group) { create(:rating_group, exercise: exercise) }

    context 'as an admin' do
      let(:user) { create(:account, :admin) }
      let(:term) { create(:term) }

      it { is_expected.to permit_authorization :new }
      it { is_expected.to permit_authorization :create }
      it { is_expected.to permit_authorization :edit }
      it { is_expected.to permit_authorization :update }
      it { is_expected.to permit_authorization :destroy }
      it { is_expected.to permit_authorization :update_position }
    end

    context 'as lecturer' do
      let(:user) { FactoryGirl.create(:account, :lecturer) }
      let(:term) { user.term_registrations.lecturers.first.term }

      it { is_expected.to permit_authorization :new }
      it { is_expected.to permit_authorization :create }
      it { is_expected.to permit_authorization :edit }
      it { is_expected.to permit_authorization :update }
      it { is_expected.to permit_authorization :destroy }
      it { is_expected.to permit_authorization :update_position }
    end

    context 'as tutor' do
      let(:user) { FactoryGirl.create(:account, :tutor) }
      let(:term) { user.term_registrations.tutors.first.term }

      it { is_expected.not_to permit_authorization :new }
      it { is_expected.not_to permit_authorization :create }
      it { is_expected.not_to permit_authorization :edit }
      it { is_expected.not_to permit_authorization :update }
      it { is_expected.not_to permit_authorization :destroy }
      it { is_expected.not_to permit_authorization :update_position }
    end

    context 'as student' do
      let(:user) { FactoryGirl.create(:account, :student) }
      let(:term) { user.term_registrations.students.first.term }

      it { is_expected.not_to permit_authorization :new }
      it { is_expected.not_to permit_authorization :create }
      it { is_expected.not_to permit_authorization :edit }
      it { is_expected.not_to permit_authorization :update }
      it { is_expected.not_to permit_authorization :destroy }
      it { is_expected.not_to permit_authorization :update_position }
    end
  end
end
