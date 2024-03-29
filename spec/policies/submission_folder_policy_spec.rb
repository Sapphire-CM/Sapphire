require 'rails_helper'

RSpec.describe SubmissionFolderPolicy do
  let(:submission_folder) { SubmissionFolder.new(submission: submission) }
  subject { described_class.new(account, submission_folder) }

  context 'as admin' do
    let(:account) { FactoryBot.create(:account, :admin) }
    let(:submission) { FactoryBot.create(:submission) }

    it { is_expected.to permit_authorization :show }
    it { is_expected.to permit_authorization :new }
    it { is_expected.to permit_authorization :create }
  end

  %I(lecturer tutor).each do |role|
    context "as #{role}" do
      let(:account) { FactoryBot.create(:account, role) }

      context 'of term' do
        let(:term_registration) { account.term_registrations.last }
        let(:term) { term_registration.term }
        let(:exercise) { FactoryBot.create(:exercise, term: term) }
        let(:submission) { FactoryBot.create(:submission, exercise: exercise) }

        it { is_expected.to permit_authorization :show }
        it { is_expected.to permit_authorization :new }
        it { is_expected.to permit_authorization :create }
      end

      context 'of other term' do
        let(:submission) { FactoryBot.create(:submission) }

        it { is_expected.not_to permit_authorization :show }
        it { is_expected.not_to permit_authorization :new }
        it { is_expected.not_to permit_authorization :create }
      end
    end
  end

  context "as student" do
    let(:account) { FactoryBot.create(:account, :student) }

    context 'of term' do
      let(:term_registration) { account.term_registrations.last }
      let(:term) { term_registration.term }
      let(:exercise) { FactoryBot.create(:exercise, term: term) }
      let(:submission) { FactoryBot.create(:submission, exercise: exercise) }

      context 'owning the submission' do
        let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

        it { is_expected.to permit_authorization :show }
        it { is_expected.to permit_authorization :new }
        it { is_expected.to permit_authorization :create }
      end

      context 'not owning the submission' do
        it { is_expected.not_to permit_authorization :show }
        it { is_expected.not_to permit_authorization :new }
        it { is_expected.not_to permit_authorization :create }
      end

    end

    context 'of other term' do
      let(:submission) { FactoryBot.create(:submission) }

      it { is_expected.not_to permit_authorization :show }
      it { is_expected.not_to permit_authorization :new }
      it { is_expected.not_to permit_authorization :create }
    end
  end
end
