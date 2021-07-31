require 'rails_helper'

RSpec.describe StaffSubmissionsController do
  render_views
  include_context 'active_admin_session_context'

  let!(:term) { FactoryGirl.create :term }
  let!(:exercise) { FactoryGirl.create :exercise, term: term }
  let!(:tutorial_group) { FactoryGirl.create :tutorial_group, term: term }
  let!(:submission) { FactoryGirl.create :submission, exercise: exercise }
  let!(:submission_asset) { FactoryGirl.create :submission_asset, submission: submission }

  describe 'GET index' do
    context 'with tutorial_group' do
      it 'works' do
        get :index, params: { exercise_id: exercise.id, tutorial_group_id: tutorial_group.id }

        expect(response).to have_http_status(:success)
      end
    end

    context 'without tutorial_group' do
      it 'works' do
        get :index, params: { exercise_id: exercise.id }

        expect(response).to have_http_status(:success)
      end
    end

    context 'without any tutorial groups' do
      it 'works' do
        TutorialGroup.destroy_all

        get :index, params: { exercise_id: exercise.id }

        expect(response).to have_http_status(:success)
      end
    end
  end
end
