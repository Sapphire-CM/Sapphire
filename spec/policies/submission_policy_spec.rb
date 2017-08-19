require 'rails_helper'

RSpec.describe SubmissionPolicy do
  subject { described_class.new(account, submission) }
  let(:submission) { FactoryGirl.create(:submission) }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    it { is_expected.to permit_authorization(:index) }
    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:new) }
    it { is_expected.to permit_authorization(:update) }
    it { is_expected.to permit_authorization(:destroy) }
    it { is_expected.to permit_authorization(:directory) }
    it { is_expected.to permit_authorization(:tree) }
  end

  context 'as a lecturer' do
    let(:term) { submission.exercise.term }
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, account: account, term: term) }

    it { is_expected.to permit_authorization(:index) }
    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:new) }
    it { is_expected.to permit_authorization(:update) }
    it { is_expected.to permit_authorization(:destroy) }
    it { is_expected.to permit_authorization(:directory) }
    it { is_expected.to permit_authorization(:tree) }
  end

  context 'as a tutor' do
    let(:term) { submission.exercise.term }
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, account: account, term: term) }

    it { is_expected.to permit_authorization(:index) }
    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:new) }
    it { is_expected.to permit_authorization(:update) }
    it { is_expected.to permit_authorization(:destroy) }
    it { is_expected.to permit_authorization(:directory) }
    it { is_expected.to permit_authorization(:tree) }
  end

  context 'as a student' do
    let(:term) { exercise.term }
    let(:exercise) { submission.exercise }
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :student, account: account, term: term) }

    context 'with exercise registration' do
      let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

      it { is_expected.not_to permit_authorization(:index) }

      it { is_expected.to permit_authorization(:show) }
      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:update) }
      it { is_expected.to permit_authorization(:destroy) }
      it { is_expected.to permit_authorization(:directory) }
      it { is_expected.to permit_authorization(:tree) }
    end

    context 'without exercise registration' do
      it { is_expected.not_to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:show) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
      it { is_expected.not_to permit_authorization(:directory) }
      it { is_expected.not_to permit_authorization(:tree) }
    end

    context 'after deadline passed' do
      before :each do
        exercise.update(deadline: 2.days.ago, late_deadline: 1.day.ago)
      end

      let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

      it { is_expected.to permit_authorization(:show) }
      it { is_expected.to permit_authorization(:directory) }
      it { is_expected.to permit_authorization(:tree) }

      it { is_expected.not_to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
    end

    context 'disabled student uploads' do
      before :each do
        exercise.update(enable_student_uploads: false)
      end

      let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

      it { is_expected.to permit_authorization(:show) }
      it { is_expected.to permit_authorization(:directory) }
      it { is_expected.to permit_authorization(:tree) }

      it { is_expected.not_to permit_authorization(:index) }
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
    end
  end

  context 'as a lecturer of another term' do
    let(:account) { FactoryGirl.create(:account) }
    let(:another_term) { FactoryGirl.create(:term) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: another_term) }

    it { is_expected.not_to permit_authorization(:index) }
    it { is_expected.not_to permit_authorization(:show) }
    it { is_expected.not_to permit_authorization(:new) }
    it { is_expected.not_to permit_authorization(:update) }
    it { is_expected.not_to permit_authorization(:destroy) }
    it { is_expected.not_to permit_authorization(:directory) }
    it { is_expected.not_to permit_authorization(:tree) }
  end

  context 'as a tutor of another term' do
    let(:account) { FactoryGirl.create(:account) }
    let(:another_term) { FactoryGirl.create(:term) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: another_term) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, term: another_term, tutorial_group: tutorial_group) }

    it { is_expected.not_to permit_authorization(:index) }
    it { is_expected.not_to permit_authorization(:show) }
    it { is_expected.not_to permit_authorization(:new) }
    it { is_expected.not_to permit_authorization(:update) }
    it { is_expected.not_to permit_authorization(:destroy) }
    it { is_expected.not_to permit_authorization(:directory) }
    it { is_expected.not_to permit_authorization(:tree) }
  end

  context 'as a student of another student group' do
    let(:account) { FactoryGirl.create(:account) }
    let(:another_term) { FactoryGirl.create(:term) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: another_term) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :student, term: another_term, tutorial_group: tutorial_group) }

    it { is_expected.not_to permit_authorization(:index) }
    it { is_expected.not_to permit_authorization(:show) }
    it { is_expected.not_to permit_authorization(:new) }
    it { is_expected.not_to permit_authorization(:update) }
    it { is_expected.not_to permit_authorization(:destroy) }
    it { is_expected.not_to permit_authorization(:directory) }
    it { is_expected.not_to permit_authorization(:tree) }
  end
end
