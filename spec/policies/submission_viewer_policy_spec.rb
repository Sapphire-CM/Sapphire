require 'rails_helper'

RSpec.describe SubmissionViewerPolicy do
  let(:submission) { FactoryGirl.create(:submission) }
  let(:term) { submission.exercise.term }

  subject { SubmissionViewerPolicy.new(account, SubmissionViewerPolicy.policy_record_with(submission: submission)) }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    it { is_expected.to permit_authorization(:show) }
  end

  context 'arbitrary account' do
    let(:account) { FactoryGirl.create(:account) }

    %I(lecturer tutor).each do |role|
      context "as a #{role}" do
        describe 'of the current term' do
          let!(:term_registration) { FactoryGirl.create(:term_registration, role, account: account, term: term) }

          it { is_expected.to permit_authorization(:show) }
        end

        describe 'of another term' do
          let!(:term_registration) { FactoryGirl.create(:term_registration, role, account: account) }

          it { is_expected.not_to permit_authorization(:show) }
        end
      end
    end

    context 'as a student' do
      describe 'of the current term' do
        let!(:term_registration) { FactoryGirl.create(:term_registration, :student, account: account, term: term) }

        it { is_expected.not_to permit_authorization(:show) }
      end

      describe 'of another term' do
        let!(:term_registration) { FactoryGirl.create(:term_registration, :student, account: account) }

        it { is_expected.not_to permit_authorization(:show) }
      end
    end
  end
end
