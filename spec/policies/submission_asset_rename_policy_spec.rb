require 'rails_helper'

RSpec.describe SubmissionAssetRenamePolicy, type: :policy do

  let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
  let(:submission_asset) { FactoryBot.create(:submission_asset, submission: submission, path: "", file: prepare_static_test_file("simple_submission.txt", rename_to: "file1.txt")) }
  let(:submission_asset_rename) { SubmissionAssetRename.new(submission: submission, submission_asset: submission_asset) }
  subject { described_class.new(account, submission_asset_rename) }

  context 'as admin' do
    let(:account) { FactoryBot.create(:account, :admin) }
    let(:submission) { FactoryBot.create(:submission) }

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

        it { is_expected.to permit_authorization :new }
        it { is_expected.to permit_authorization :create }
      end

      context 'of other term' do
        let(:submission) { FactoryBot.create(:submission) }

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

        it { is_expected.to permit_authorization :new }
        it { is_expected.to permit_authorization :create }
      end

      context 'not owning the submission' do
        it { is_expected.not_to permit_authorization :new }
        it { is_expected.not_to permit_authorization :create }
      end

    end

    context 'of other term' do
      let(:submission) { FactoryBot.create(:submission) }

      it { is_expected.not_to permit_authorization :new }
      it { is_expected.not_to permit_authorization :create }
    end
  end
end
