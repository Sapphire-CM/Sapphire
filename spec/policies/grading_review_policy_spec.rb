require 'rails_helper'

RSpec.describe GradingReviewPolicy do
  subject { GradingReviewPolicy.new(account, term) }

  let(:term) { FactoryGirl.create(:term) }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    it { is_expected.to permit_authorization(:index) }
    it { is_expected.to permit_authorization(:show) }
  end

  %I(lecturer tutor).each do |role|
    context "as a #{role}" do
      let(:account) { FactoryGirl.create(:account) }
      let!(:term_registration) { FactoryGirl.create(:term_registration, role, term: term, account: account) }

      it { is_expected.to permit_authorization(:index) }
      it { is_expected.to permit_authorization(:show) }
    end
  end

  context 'as a student' do
    let(:account) { FactoryGirl.create(:account) }
    let!(:term_registration) { FactoryGirl.create(:term_registration, :student, term: term, account: account) }

    it { is_expected.not_to permit_authorization(:index) }
    it { is_expected.not_to permit_authorization(:show) }
  end
end
