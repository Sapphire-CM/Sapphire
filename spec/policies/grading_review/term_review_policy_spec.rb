require 'rails_helper'

RSpec.describe GradingReview::TermReviewPolicy do
  subject { described_class.new(account, record) }

  let(:term) { FactoryGirl.create(:term) }
  let(:term_registration_to_view) { FactoryGirl.create(:term_registration, :student, term: term) }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    describe 'collections' do
      let(:record) { described_class.term_policy_record(term) }

      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      let(:record) { GradingReview::TermReview.new(term_registration: term_registration_to_view) }

      it { is_expected.to permit_authorization(:show) }
    end
  end

  %I(lecturer tutor).each do |role|
    context "as a #{role}" do
      let(:account) { FactoryGirl.create(:account) }
      let!(:term_registration) { FactoryGirl.create(:term_registration, role, term: term, account: account) }

      describe 'collections' do
        let(:record) { described_class.term_policy_record(term) }

        it { is_expected.to permit_authorization(:index) }
      end

      describe 'members' do
        let(:record) { GradingReview::TermReview.new(term_registration: term_registration_to_view) }

        it { is_expected.to permit_authorization(:show) }
      end
    end
  end

  context 'as a student' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :student, term: term, account: account) }

    describe 'collections' do
      let(:record) { described_class.term_policy_record(term) }

      it { is_expected.not_to permit_authorization(:index) }
    end

    describe 'members' do
      let(:record) { GradingReview::TermReview.new(term_registration: term_registration_to_view) }

      it { is_expected.not_to permit_authorization(:show) }
    end
  end
end
