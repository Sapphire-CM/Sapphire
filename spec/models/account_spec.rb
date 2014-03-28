require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Account do
  context "student" do
    let(:term) {FactoryGirl.create(:term)}
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let(:user) do
      account = FactoryGirl.create(:account)
      student_group = FactoryGirl.create(:student_group, tutorial_group: tutorial_group)
      student_registration = FactoryGirl.create(:student_registration, student: account, student_group: student_group)
      account
    end

    it "should be able to tell if the account is a student of a term" do
      expect(user).to be_student_of_term(term)
      expect(user).not_to be_student_of_term(FactoryGirl.create(:term))
    end
  end

  context "student" do
    let(:term) {FactoryGirl.create(:term)}
    let(:user) {FactoryGirl.create(:account, :admin)}

    it "should be able to tell that the account is not a student of a term" do
      expect(user).not_to be_student_of_term(term)
    end
  end
end