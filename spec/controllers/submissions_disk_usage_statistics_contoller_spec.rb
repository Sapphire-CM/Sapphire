require 'rails_helper'

RSpec.describe SubmissionsDiskUsageStatisticsController, type: :controller do
  render_views
  include_context 'active_admin_session_context'
  let!(:term) { FactoryGirl.create :term}

  describe 'GET show' do
    context 'exercises exist' do
      let!(:exercise) { FactoryGirl.create :exercise, term: term }
      let!(:submission) { FactoryGirl.create(:submission, exercise: exercise) }
      let!(:submission_asset) { FactoryGirl.create(:submission_asset, :plain_text, submission: submission) }

      it 'returns http success' do
        get :show, term_id: term.id
        expect(response).to have_http_status(:success)
        expect(response.body).to include('Total on File System')
        expect(response.body).to include('Average')
        expect(response.body).to include('Minimum')
        expect(response.body).to include('Maximum')
        expect(response).to render_template("submissions_disk_usage_statistics/_statistics_table")
        expect(assigns(:term)).to eq(term)
      end
    end
    
    context 'no exercises exist' do
      it 'returns http success' do
        get :show, term_id: term.id
        expect(response).to have_http_status(:success)
        expect(response.body).to include('No exercises present.')
        expect(assigns(:term)).to eq(term)
      end
    end
  end
end
