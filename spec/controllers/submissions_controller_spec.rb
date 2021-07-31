require 'rails_helper'

RSpec.describe SubmissionsController, type: :controller do
  include_context "active student session with submission"

  describe 'GET #show' do
    it 'redirects to the SubmissionTreeController' do
      get :show, params: { id: submission.id }
    end
  end
end
