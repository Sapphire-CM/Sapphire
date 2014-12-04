require 'rails_helper'

describe SubmissionViewersController do
  describe "GET 'show'" do
    it "returns http success" do
      admin = FactoryGirl.create(:account, :admin)
      sign_in(admin)

      exercise = FactoryGirl.create(:exercise, :with_viewer)
      submission = FactoryGirl.create(:submission, exercise: exercise)

      get 'show', id: submission.id

      expect(response.status).to eq(200)
      expect(response).to be_success
    end
  end
end
