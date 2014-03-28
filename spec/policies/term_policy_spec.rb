require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TermPolicy do
  subject { Pundit.policy(user, term) }

  let(:term) { FactoryGirl.create(:term) }

  context "as a student" do
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let(:user) do
      account = FactoryGirl.create(:account)
      student_group = FactoryGirl.create(:student_group, tutorial_group: tutorial_group)
      student_registration = FactoryGirl.create(:student_registration, student: account, student_group: student_group)
      account
    end

    it { should permit :student }
  end

  context "as an admin" do
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let(:user) { FactoryGirl.create(:account, :admin) }

    it { should_not permit :student }
  end
end