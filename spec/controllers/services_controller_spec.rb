require 'rails_helper'

RSpec.describe ServicesController do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryBot.create :term }
  let(:exercise) { FactoryBot.create :exercise, term: term }
  let(:service) { FactoryBot.create :website_fetcher_service, exercise: exercise }

  describe 'GET index' do
    it 'assigns all services as @services' do
      FactoryBot.create_list :website_fetcher_service, 4, exercise: exercise

      get :index, params: { term_id: term.id, exercise_id: exercise.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:services)).to match_array(exercise.services)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested course as @course' do
      get :edit, params: { term_id: term.id, exercise_id: exercise.id, id: service.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:service)).to eq(service)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      [true, false].each do |active|
        it 'activates the requested service' do
          valid_attributes = {
            term_id: term.id,
            exercise_id: exercise.id,
            id: service.id,
            service: {
              active: active
            }
          }

          put :update, params: valid_attributes

          service.reload
          expect(response).to redirect_to(term_exercise_services_path(term, exercise))
          expect(assigns(:service)).to eq(service)
          expect(service.active).to eq active
        end
      end
    end

    describe 'with invalid params' do
      # can not happen
    end
  end
end
