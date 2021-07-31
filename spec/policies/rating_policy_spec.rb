require 'rails_helper'

RSpec.describe RatingPolicy do
  subject { described_class.new(account, rating) }

  context 'as admin' do
    let(:account) { FactoryBot.create(:account, :admin) }
    let(:rating) { FactoryBot.create(:fixed_points_deduction_rating) }

    it { is_expected.to permit_authorization(:new) }
    it { is_expected.to permit_authorization(:create) }
    it { is_expected.to permit_authorization(:edit) }
    it { is_expected.to permit_authorization(:update) }
    it { is_expected.to permit_authorization(:destroy) }
    it { is_expected.to permit_authorization(:update_position) }
  end

  context 'as lecturer' do
    let(:account) { FactoryBot.create(:account, :lecturer) }
    let(:exercise) { FactoryBot.create(:exercise, term: term) }
    let(:rating_group) { FactoryBot.create(:rating_group, exercise: exercise) }
    let(:rating) { FactoryBot.create(:fixed_points_deduction_rating, rating_group: rating_group) }

    context 'of term' do
      let(:term_registration) { account.term_registrations.last }
      let(:term) { term_registration.term }

      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
      it { is_expected.to permit_authorization(:destroy) }
      it { is_expected.to permit_authorization(:update_position) }
    end

    context 'of other term' do
      let(:term) { FactoryBot.create(:term) }

      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:edit) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
      it { is_expected.not_to permit_authorization(:update_position) }
    end
  end

  %I(tutor student).each do |role|
    context "as #{role}" do
      let(:account) { FactoryBot.create(:account, role) }
      let(:exercise) { FactoryBot.create(:exercise, term: term) }
      let(:rating_group) { FactoryBot.create(:rating_group, exercise: exercise) }
      let(:rating) { FactoryBot.create(:fixed_points_deduction_rating, rating_group: rating_group) }
      let(:term) { term_registration.term }

      let(:term_registration) { account.term_registrations.last }

      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:edit) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
      it { is_expected.not_to permit_authorization(:update_position) }
    end
  end
end
