require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  describe 'GET #index' do
    include_context 'active_admin_session_context'

    let(:term) { FactoryGirl.create(:term) }
    let(:another_term) { FactoryGirl.create(:term) }

    it 'renders a 404 response if a format other than json is requested' do
      get :index, term_id: term.id, format: :html

      expect(response).to have_http_status(:not_found)
    end

    describe 'scoping' do
      let!(:events) { FactoryGirl.create_list(:event, 5, term: term) }
      let!(:other_events) { FactoryGirl.create_list(:event, 5, term: another_term) }

      it 'only assigns events of term' do
        get :index, term_id: term.id, format: :json

        expect(assigns(:events)).to match_array(events)
        expect(assigns(:events)).not_to match_array(other_events)
      end
    end

    describe 'paging' do
      let!(:events) do
        (1..6).map { |i| FactoryGirl.create_list(:event, 5, term: term, created_at: Time.now - i * 10.minutes, updated_at: Time.now - i * 10.minutes) }.flatten
      end

      it 'assigns @events with the first page of events when no page param is given' do
        get :index, term_id: term.id, format: :json

        expect(response).to have_http_status(:success)
        expect(assigns(:events)).to match(events.first(25))
      end

      it 'assigns @events with the given page of events when page param is present' do
        get :index, term_id: term.id, page: 2, format: :json

        expect(response).to have_http_status(:success)
        expect(assigns(:events)).to match(events.last(5))
      end
    end
  end
end
