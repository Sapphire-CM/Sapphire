require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TermPolicy do
  subject { Pundit.policy(user, term) }

  let(:term) { FactoryGirl.create(:term) }

  context "as a student" do
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let(:user) do
      account = FactoryGirl.create(:account)
      FactoryGirl.create(:term_registration, :student, account: account, term: term, tutorial_group: tutorial_group)
      account
    end

    it { should permit_authorization :student }
    it { should_not permit_authorization :tutor }
  end

  context "as an admin" do
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let(:user) { FactoryGirl.create(:account, :admin) }

    it { should_not permit_authorization :student }
    it { should_not permit_authorization :tutor }
  end

  context "as a tutor" do
    let(:user) {
      account = FactoryGirl.create(:account, :tutor)
      FactoryGirl.create(:term_registration, :tutor, account: account, term: term, tutorial_group: tutorial_group)
      account
    }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }

    it { should_not permit_authorization :student }
    it { should permit_authorization :tutor }
  end
end