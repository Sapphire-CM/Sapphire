require 'rails_helper'

RSpec.describe StudentResultsPolicy do
  subject { described_class.new(account, policy_record) }
  let(:term_policy_record) { described_class.term_policy_record(term) }
  let(:submission_policy_record) { described_class.policy_record_with({submission: submission}) }

  context 'as admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    describe 'collections' do
      let(:policy_record) { term_policy_record }
      let(:term) { FactoryGirl.create(:term) }

      it { is_expected.not_to permit_authorization(:index) }
    end

    describe 'members' do
      let(:policy_record) { submission_policy_record }
      let(:submission) { FactoryGirl.create(:submission) }

      it { is_expected.not_to permit_authorization(:show) }
    end
  end

  %I(lecturer tutor).each do |role|
    context "as #{role}" do
      let(:account) { FactoryGirl.create(:account, role) }

      context 'of term' do
        let(:term_registration) { account.term_registrations.last }
        let(:term) { term_registration.term }

        describe 'collections' do
          let(:policy_record) { term_policy_record }

          it { is_expected.not_to permit_authorization(:index) }
        end

        describe 'members' do
          let(:policy_record) { submission_policy_record }
          let(:exercise) { FactoryGirl.create(:exercise, term: term) }
          let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }

          it { is_expected.not_to permit_authorization(:show) }
        end
      end

      context 'of other term' do
        let(:term) { FactoryGirl.create(:term) }

        describe 'collections' do
          let(:policy_record) { term_policy_record }

          it { is_expected.not_to permit_authorization(:index) }
        end

        describe 'members' do
          let(:policy_record) { submission_policy_record }
          let(:exercise) { FactoryGirl.create(:exercise, term: term) }
          let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }

          it { is_expected.not_to permit_authorization(:show) }
        end
      end
    end
  end

  context "as student" do
    let(:account) { FactoryGirl.create(:account, :student) }

    context 'of term' do
      let(:term_registration) { account.term_registrations.last }
      let(:term) { term_registration.term }

      describe 'collections' do
        let(:policy_record) { term_policy_record }

        it { is_expected.to permit_authorization(:index) }
      end

      describe 'members' do
        let(:policy_record) { submission_policy_record }
        let(:exercise) { FactoryGirl.create(:exercise, term: term) }
        let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }

        context 'owning submission and results are published' do
          let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }
          before :each do
            exercise.result_publications.update_all(published: true)
          end

          it { is_expected.to permit_authorization(:show) }
        end

        context 'not owning submission and results are published' do
          before :each do
            exercise.result_publications.update_all(published: true)
          end

          it { is_expected.not_to permit_authorization(:show) }
        end

        context 'owning submission and results are unpublished' do
          let!(:exercise_registration) { FactoryGirl.create(:exercise_registration, exercise: exercise, term_registration: term_registration, submission: submission) }

          it { is_expected.not_to permit_authorization(:show) }
        end

        context 'not owning submission and results are unpublished' do
          it { is_expected.not_to permit_authorization(:show) }
        end
      end
    end

    context 'of other term' do
      let(:term) { FactoryGirl.create(:term) }

      describe 'collections' do
        let(:policy_record) { term_policy_record }

        it { is_expected.not_to permit_authorization(:index) }
      end

      describe 'members' do
        let(:policy_record) { submission_policy_record }
        let(:exercise) { FactoryGirl.create(:exercise, term: term) }
        let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }

        it { is_expected.not_to permit_authorization(:show) }
      end
    end
  end
end
