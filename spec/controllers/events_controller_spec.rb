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

    describe 'filtering' do
      event_type_service = EventTypeService.new
      types = ["Admin", "Submissions", "Student Groups", "Results"]
      
      types_chosen = types.sample([*1..types.count].sample)
      event_types_chosen = []
      types_chosen.each do |type|
        event_types_chosen += event_type_service.types[type]
      end

      types_not_chosen = types - types_chosen
      event_types_not_chosen = []
      types_not_chosen.each do |type|
        event_types_not_chosen += event_type_service.types[type]
      end

      let!(:events) { 10.times.map { FactoryGirl.create(:event, type: event_types_chosen.sample, term_id: term.id) }}
      let!(:other_event) { FactoryGirl.create(:event, type: event_types_not_chosen.sample, term_id: term.id )}

      it 'only shows events of term and scope' do
        params = { "scopes" => types_chosen, term_id: term.id }
        get :index, params, format: :json
        
        expect(assigns(:events)).not_to include(other_event)
       end
    end
=begin
     describe 'filtering' do
      event_type_service = EventTypeService.new
      types = ["Admin", "Submissions", "Student Groups", "Results"]
      event_types = []

      types.each do |type|
        event_types += event_type_service.types[type]
      end

      

      let!(:events) { 10.times.map { FactoryGirl.create(:event, type: event_types.sample, term_id: 1) }}
      let!(:submission_event) { FactoryGirl.create(:event, type: "Events::Submission::Updated", term_id: term.id )}

      it 'only shows events of term and scope' do
        params = { "scopes" => ["Admin"], term_id: 1 }
        get :index, params, format: :json
    
        expect(assigns(:events)).not_to include(submission_event)
       end
    end
=end
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
