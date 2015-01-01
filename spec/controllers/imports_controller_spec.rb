require 'rails_helper'

RSpec.describe ImportsController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      import: {
        term_id: term.id,
        file: Rack::Test::UploadedFile.new(prepare_static_test_file('import_data.csv'), 'text/csv'),
        import_options: {
          matching_groups: 'first',
          tutorial_groups_regexp: "\\AT(?<tutorial>[\\d]+)\\z",
          headers_on_first_line: '1',
          column_separator: ';',
          quote_char: '"',
          decimal_separator: ',',
          thousands_separator: '.',
        }
      }
    }
  end

  let(:invalid_attributes) do
    {
      import: {
        term_id: term.id,
        file: '',
      }
    }
  end

  let(:term) { FactoryGirl.create :term }
  let(:import) { FactoryGirl.create :import, term: term }

  describe 'GET show' do
    it 'assigns the requested import as @import' do
      get :show, term_id: term.id, id: import.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:import)).to eq(import)
      expect(assigns(:import)).to be_decorated
    end
  end

  describe 'GET new' do
    it 'assigns a new import as @import' do
      get :new, term_id: term.id

      expect(response).to have_http_status(:success)
      expect(assigns(:import)).to be_a_new(Import)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new StudentImport' do
        valid_attributes[:term_id] = term.id

        expect do
          post :create, valid_attributes
        end.to change(Import, :count).by(1)

        expect(response).to redirect_to(term_import_path(term, assigns(:import)))
        expect(assigns(:import)).to be_a(Import)
        expect(assigns(:import)).to be_persisted
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved import as @import' do
        invalid_attributes[:term_id] = term.id

        post :create, invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:import)).to be_a_new(Import)
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested import' do
        valid_attributes[:term_id] = term.id
        valid_attributes[:id] = import.id

        expect {
          put :update, valid_attributes
          import.reload
        }.to change(import, :updated_at)

        expect(response).to redirect_to(results_term_import_path(term, import))
        expect(import.running?).to eq(true)
      end
    end

    describe 'with invalid params' do
      # can not happen
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested import' do
      import.reload # trigger creation

      expect do
        delete :destroy, term_id: term.id, id: import.id
      end.to change(Import, :count).by(-1)

      expect(response).to redirect_to(new_term_import_path(term))
    end
  end

  describe 'GET full_mapping_table' do
    it 'assigns the requested import as @import' do
      xhr :get, :full_mapping_table, term_id: term.id, id: import.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:import)).to eq(import)
      expect(assigns(:entries)).to eq(import.values)
      expect(assigns(:column_count)).to eq(import.column_count)
    end
  end

  describe 'GET results' do
    it 'assigns the requested import as @import' do
      get :results, term_id: term.id, id: import.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:import)).to eq(import)
    end
  end
end
