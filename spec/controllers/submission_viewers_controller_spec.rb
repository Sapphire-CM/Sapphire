require 'spec_helper'

describe SubmissionViewersController do

  describe "GET 'show'" do
    it "returns http success" do
      admin = FactoryGirl.create(:admin_account)
      sign_in(admin)

      exercise = FactoryGirl.create(:exercise, :with_viewer)
      submission = FactoryGirl.create(:submission, exercise: exercise)

      get 'show', id: submission.id

      response.status.should eq(200)
      response.should be_success
    end
  end

end
