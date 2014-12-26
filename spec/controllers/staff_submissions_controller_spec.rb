require 'rails_helper'

RSpec.describe StaffSubmissionsController do
  render_views
  include_context 'active_admin_session_context'

  let!(:term) { FactoryGirl.create :term }
  let!(:exercise) { FactoryGirl.create :exercise, term: term }
  let!(:tutorial_group) { FactoryGirl.create :tutorial_group, term: term }

  describe 'GET index' do
    context 'with tutorial_group' do
      it 'works' do
        get :index, exercise_id: exercise.id, tutorial_group_id: tutorial_group.id

        expect(response).to have_http_status(:success)
      end
    end

    context 'without tutorial_group' do
      it 'works' do
        get :index, exercise_id: exercise.id

        expect(response).to have_http_status(:success)
      end
    end
  end

  it 'needs to be implemented'
end
