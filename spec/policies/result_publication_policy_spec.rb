require 'rails_helper'

describe ResultPublicationPolicy do
  describe 'resolving through Pundit' do
    let(:user) { create(:account, :admin) }
    let(:result_publication) { create(:result_publication) }

    it 'returns a ResultPublicationPolicy' do
      expect(Pundit.policy(user, result_publication)).to be_a(ResultPublicationPolicy)
    end
  end

  describe '#index?' do
    subject { ResultPublicationPolicy.new(user, policy_record) }
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
    subject { ResultPublicationPolicy.new(user, result_publication) }

    let!(:exercise) { create(:exercise, term: term) }
    let!(:tutorial_group) { create(:tutorial_group, term: term) }

    let(:result_publication) { ResultPublication.for(exercise: exercise, tutorial_group: tutorial_group) }

    context 'as an admin' do
      let(:user) { create(:account, :admin) }
      let(:term) { create(:term) }

      it { is_expected.to permit_authorization :publish }
      it { is_expected.to permit_authorization :conceal }
      it { is_expected.to permit_authorization :publish_all }
      it { is_expected.to permit_authorization :conceal_all }
    end

    context 'as lecturer' do
      let(:user) { FactoryGirl.create(:account, :lecturer) }
      let(:term) { user.term_registrations.lecturers.first.term }

      it { is_expected.to permit_authorization :publish }
      it { is_expected.to permit_authorization :conceal }
      it { is_expected.to permit_authorization :publish_all }
      it { is_expected.to permit_authorization :conceal_all }
    end

    context 'as tutor' do
      let(:user) { FactoryGirl.create(:account, :tutor) }
      let(:term) { user.term_registrations.tutors.first.term }

      it { is_expected.not_to permit_authorization :publish }
      it { is_expected.not_to permit_authorization :conceal }
      it { is_expected.not_to permit_authorization :publish_all }
      it { is_expected.not_to permit_authorization :conceal_all }
    end

    context 'as student' do
      let(:user) { FactoryGirl.create(:account, :student) }
      let(:term) { user.term_registrations.students.first.term }

      it { is_expected.not_to permit_authorization :publish }
      it { is_expected.not_to permit_authorization :conceal }
      it { is_expected.not_to permit_authorization :publish_all }
      it { is_expected.not_to permit_authorization :conceal_all }
    end
  end
end
