require 'rails_helper'

RSpec.describe CommentPolicy do
  subject { described_class.new(account, comment) }

  let(:term) { FactoryBot.create :term }
  let(:exercise) { FactoryBot.create :exercise, :with_ratings, term: term }
  let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
  let(:commentable) { submission.submission_evaluation }

  context 'as admin' do
    let(:account) { FactoryBot.create(:account, :admin) }
    let(:comment) { FactoryBot.create(:feedback_comment, account: account, commentable: commentable) }

    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:edit) }
    it { is_expected.to permit_authorization(:update) }
    it { is_expected.to permit_authorization(:destroy) }
    it { is_expected.to permit_authorization(:create) }
  end

  context 'as lecturer' do
    let(:account) { FactoryBot.create(:account, :lecturer) }
    let(:comment) { FactoryBot.create(:feedback_comment, account: account, commentable: commentable, term: term) }

    context 'of term' do
      let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: account, term: term) }

        it { is_expected.to permit_authorization(:new) }
        it { is_expected.to permit_authorization(:create) }
        it { is_expected.to permit_authorization(:edit) }
        it { is_expected.to permit_authorization(:update) }
        it { is_expected.to permit_authorization(:destroy) }

    end

    context 'of other term' do
      let(:other_term) { FactoryBot.create(:term) }
      let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: account, term: other_term) }

        it { is_expected.not_to permit_authorization(:new) }
        it { is_expected.not_to permit_authorization(:create) }
        it { is_expected.not_to permit_authorization(:edit) }
        it { is_expected.not_to permit_authorization(:update) }
        it { is_expected.not_to permit_authorization(:destroy) }

    end

  end

  context 'as tutor' do
    let(:account) { FactoryBot.create(:account, :tutor) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, account: account, term: term) }
    let(:comment) { FactoryBot.create(:feedback_comment, account: account, commentable: commentable, term: term) }

    it { is_expected.to permit_authorization(:new) }
    it { is_expected.to permit_authorization(:edit) }
    it { is_expected.to permit_authorization(:update) }
    it { is_expected.to permit_authorization(:destroy) }
    it { is_expected.to permit_authorization(:create) }
  end

  context 'as student' do
    let(:account) { FactoryBot.create(:account, :student) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, account: account, term: term) }
    let(:comment) { FactoryBot.create(:feedback_comment, account: account, commentable: commentable) }

    it { is_expected.not_to permit_authorization(:new) }
    it { is_expected.not_to permit_authorization(:edit) }
    it { is_expected.not_to permit_authorization(:update) }
    it { is_expected.not_to permit_authorization(:destroy) }
    it { is_expected.not_to permit_authorization(:create) }
  end
end
