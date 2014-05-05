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
    it { should_not permit :tutor }
  end

  context "as an admin" do
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let(:user) { FactoryGirl.create(:account, :admin) }

    it { should_not permit :student }
    it { should_not permit :tutor }
  end

  context "as a tutor" do
    let(:user) {
      account = FactoryGirl.create(:account, :tutor)
      FactoryGirl.create(:tutor_registration, tutor: account, tutorial_group: tutorial_group)
      account
    }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }

    it { should_not permit :student }
    it { should permit :tutor }
  end
end