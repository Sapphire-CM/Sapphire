require 'rails_helper'

RSpec.describe StudentResultsPolicy do
  subject { described_class.new(account, policy_record) }
  let(:term_policy_record) { described_class.term_policy_record(term) }
  let(:submission_policy_record) { described_class.policy_record_with({submission_review: GradingReview::SubmissionReview.new(exercise_registration: exercise_registration) }) }

  context 'as admin' do
    let(:account) { FactoryBot.create(:account, :admin) }

    describe 'collections' do
      let(:policy_record) { term_policy_record }
      let(:term) { FactoryBot.create(:term) }

      it { is_expected.not_to permit_authorization(:index) }
    end

    describe 'members' do
      let(:term) { FactoryBot.create(:term) }
      let(:policy_record) { submission_policy_record }

      let(:exercise) { FactoryBot.create(:exercise, term: term) }
      let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
      let(:term_registration) { FactoryBot.create(:term_registration, term: term) }
      let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, submission: submission, term_registration: term_registration) }

      it { is_expected.not_to permit_authorization(:show) }
    end
  end

  %I(lecturer tutor).each do |role|
    context "as #{role}" do
      let(:account) { FactoryBot.create(:account, role) }

      context 'of term' do
        let(:term_registration) { account.term_registrations.last }
        let(:term) { term_registration.term }

        describe 'collections' do
          let(:policy_record) { term_policy_record }

          it { is_expected.not_to permit_authorization(:index) }
        end

        describe 'members' do
          let(:policy_record) { submission_policy_record }
          let(:exercise) { FactoryBot.create(:exercise, term: term) }
          let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
          let(:term_registration) { FactoryBot.create(:term_registration) }
          let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, submission: submission, term_registration: term_registration) }

          it { is_expected.not_to permit_authorization(:show) }
        end
      end

      context 'of other term' do
        let(:term) { FactoryBot.create(:term) }

        describe 'collections' do
          let(:policy_record) { term_policy_record }

          it { is_expected.not_to permit_authorization(:index) }
        end

        describe 'members' do
          let(:policy_record) { submission_policy_record }
          let(:exercise) { FactoryBot.create(:exercise, term: term) }
          let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
          let(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, tutorial_group: tutorial_group) }
          let!(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
          let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, submission: submission, term_registration: term_registration) }

          it { is_expected.not_to permit_authorization(:show) }
        end
      end
    end
  end

  context "as student" do
    let(:account) { FactoryBot.create(:account, :student) }

    context 'of term' do
      let(:term_registration) { account.term_registrations.last }
      let(:term) { term_registration.term }

      describe 'collections' do
        let(:policy_record) { term_policy_record }

        it { is_expected.to permit_authorization(:index) }
      end

      describe 'members' do
        let(:policy_record) { submission_policy_record }
        let(:exercise) { FactoryBot.create(:exercise, term: term) }
        let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
        let(:other_term_registration) { FactoryBot.create(:term_registration, term: term) }

        context 'owning submission and results are published' do
          let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }
          before :each do
            exercise.result_publications.update_all(published: true)
          end

          it { is_expected.to permit_authorization(:show) }
        end

        context 'not owning submission and results are published' do
          before :each do
            exercise.result_publications.update_all(published: true)
          end

          let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: other_term_registration, submission: submission)}
          it { is_expected.not_to permit_authorization(:show) }
        end

        context 'owning submission and results are unpublished' do
          let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

          it { is_expected.not_to permit_authorization(:show) }
        end

        context 'not owning submission and results are unpublished' do
          let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, term_registration: other_term_registration, submission: submission)}

          it { is_expected.not_to permit_authorization(:show) }
        end
      end
    end

    context 'of other term' do
      let(:other_term) { FactoryBot.create(:term) }

      describe 'collections' do
        let(:term) { other_term }
        let(:policy_record) { term_policy_record }

        it { is_expected.not_to permit_authorization(:index) }
      end

      describe 'members' do
        let(:policy_record) { submission_policy_record }
        let(:exercise) { FactoryBot.create(:exercise, term: other_term) }
        let(:term_registration) { FactoryBot.create(:term_registration, term: other_term)}
        let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
        let!(:exercise_registration) { FactoryBot.create(:exercise_registration, exercise: exercise, submission: submission, term_registration: term_registration) }

        it { is_expected.not_to permit_authorization(:show) }
      end
    end
  end
end
