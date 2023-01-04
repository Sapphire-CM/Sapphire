require 'rails_helper'

RSpec.describe SubmissionStructure::TreePolicy do
  subject { described_class.new(account, tree) }

  let(:submission) { FactoryBot.create(:submission) }
  let(:tree) { SubmissionStructure::Tree.new(submission: submission) }

  shared_examples "having read permissions" do
    it { is_expected.to permit_authorization(:show) }
    it { is_expected.to permit_authorization(:directory) }
  end

  shared_examples "having no read permissions" do
    it { is_expected.not_to permit_authorization(:show) }
    it { is_expected.not_to permit_authorization(:directory) }
  end

  shared_examples "having write permissions" do
    it { is_expected.to permit_authorization(:destroy) }
    it { is_expected.to permit_authorization(:rename_folders) }
    it { is_expected.to permit_authorization(:update_folder_name) }
  end

  shared_examples "having no write permissions" do
    it { is_expected.not_to permit_authorization(:destroy) }
    it { is_expected.not_to permit_authorization(:rename_folders) }
    it { is_expected.not_to permit_authorization(:update_folder_name) }
  end


  context 'as an admin' do
    let(:account) { FactoryBot.create(:account, :admin) }

    it_behaves_like "having read permissions"
    it_behaves_like "having write permissions"
  end

  context 'as a lecturer' do
    let(:term) { submission.exercise.term }
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: account, term: term) }

    it_behaves_like "having read permissions"
    it_behaves_like "having write permissions"
  end

  context 'as a tutor' do
    let(:term) { submission.exercise.term }
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, account: account, term: term) }

    it_behaves_like "having read permissions"
    it_behaves_like "having write permissions"
  end

  context 'as a student' do
    let(:term) { exercise.term }
    let(:exercise) { submission.exercise }
    let(:account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, account: account, term: term) }

    context 'with exercise registration' do
      let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

      it_behaves_like "having read permissions"
      it_behaves_like "having write permissions"
    end

    context 'without exercise registration' do
      it_behaves_like "having no read permissions"
      it_behaves_like "having no write permissions"
    end

    context 'after deadline passed' do
      before :each do
        exercise.update(deadline: 2.days.ago, late_deadline: 1.day.ago)
      end

      let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

      it_behaves_like "having read permissions"
      it_behaves_like "having no write permissions"
    end

    context 'disabled student uploads' do
      before :each do
        exercise.update(enable_student_uploads: false)
      end

      let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

      it_behaves_like "having read permissions"
      it_behaves_like "having no write permissions"
    end
  end

  context 'as a lecturer of another term' do
    let(:account) { FactoryBot.create(:account) }
    let(:another_term) { FactoryBot.create(:term) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, term: another_term) }

    it_behaves_like "having no read permissions"
    it_behaves_like "having no write permissions"
  end

  context 'as a tutor of another term' do
    let(:account) { FactoryBot.create(:account) }
    let(:another_term) { FactoryBot.create(:term) }
    let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: another_term) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, term: another_term, tutorial_group: tutorial_group) }

    it_behaves_like "having no read permissions"
    it_behaves_like "having no write permissions"
  end

  context 'as a student of another student group' do
    let(:account) { FactoryBot.create(:account) }
    let(:another_term) { FactoryBot.create(:term) }
    let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: another_term) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, term: another_term, tutorial_group: tutorial_group) }

    it_behaves_like "having no read permissions"
    it_behaves_like "having no write permissions"
  end
end
