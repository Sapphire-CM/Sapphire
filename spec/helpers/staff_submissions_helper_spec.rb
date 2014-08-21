require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the StaffSubmissionsHelper. For example:
#
# describe StaffSubmissionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe StaffSubmissionsHelper do
  describe "staff_submission_title" do
    it "should generate the appropriate title for a submission with a student group" do
      submission = FactoryGirl.create(:submission, :with_student_group_registration, student_group_title: "Group 01")

      helper.staff_submission_title(submission).should eq("Submission of Group 01")
    end

    it "should generate the appropriate title for a submission without a student group" do
      solitary_exercise = FactoryGirl.create(:exercise)
      group_exercise = FactoryGirl.create(:exercise, :group_exercise)

      solitary_submission = FactoryGirl.create(:submission, exercise: solitary_exercise)
      group_submission = FactoryGirl.create(:submission, exercise: group_exercise)

      helper.staff_submission_title(solitary_submission).should eq("Submission of unknown student")
      helper.staff_submission_title(group_submission).should eq("Submission of unknown group")
    end
  end
end
