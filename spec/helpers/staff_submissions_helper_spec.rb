require 'rails_helper'

describe StaffSubmissionsHelper do
  describe 'staff_submission_title' do
    it 'generates the appropriate title for a submission without a student group' do
      solitary_exercise = FactoryGirl.create(:exercise)
      group_exercise = FactoryGirl.create(:exercise, :group_exercise)

      solitary_submission = FactoryGirl.create(:submission, exercise: solitary_exercise)
      group_submission = FactoryGirl.create(:submission, exercise: group_exercise)

      expect(helper.staff_submission_title(solitary_submission)).to eq('Submission of unknown author')
      expect(helper.staff_submission_title(group_submission)).to eq('Submission of unknown student group')
    end
  end
end
