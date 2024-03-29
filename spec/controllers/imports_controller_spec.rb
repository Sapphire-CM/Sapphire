require 'rails_helper'

RSpec.describe ImportsController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      import: {
        term_id: term.id,
        file: Rack::Test::UploadedFile.new(prepare_static_test_file('import_data.csv'), 'text/csv'),
        import_options_attributes: {
          matching_groups: 'first_match',
          tutorial_groups_regexp: '\\AT(?<tutorial>[\\d]+)\\z',
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

  let(:term) { FactoryBot.create :term }
  let(:import) { FactoryBot.create :import, term: term }

  describe 'GET show' do
    it 'assigns the requested import as @import' do
      get :show, params: { term_id: term.id, id: import.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:import)).to eq(import)
    end
  end

  describe 'GET new' do
    context 'with existing imports to list' do
      it 'assigns a new import as @import' do
        FactoryBot.create_list :import, 4, term: term

        get :new, params: { term_id: term.id }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:_import_list)
        expect(response).to render_template(:new)
        expect(assigns(:import)).to be_a_new(Import)
      end
    end

    context 'without existing imports to list' do
      it 'assigns a new import as @import' do
        get :new, params: { term_id: term.id }

        expect(response).to have_http_status(:success)
        expect(response).not_to render_template(:_import_list)
        expect(response).to render_template(:new)
        expect(assigns(:import)).to be_a_new(Import)
      end
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new StudentImport with default values' do
        valid_attributes[:term_id] = term.id

        expect do
          post :create, params: valid_attributes
        end.to change(Import, :count).by(1)

        expect(response).to redirect_to(term_import_path(term, assigns(:import)))
        expect(assigns(:import)).to be_a(Import)
        expect(assigns(:import)).to be_persisted
      end

      it 'creates a new StudentImport with non-default values' do
        valid_attributes[:term_id] = term.id
        valid_attributes[:import][:file] = Rack::Test::UploadedFile.new(prepare_static_test_file('import_data_commas_single_quotes.csv'), 'text/csv')
        valid_attributes[:import][:import_options_attributes][:column_separator] = ','
        valid_attributes[:import][:import_options_attributes][:quote_char] = "'"

        expect do
          post :create, params: valid_attributes
        end.to change(Import, :count).by(1)

        expect(response).to redirect_to(term_import_path(term, assigns(:import)))
        expect(assigns(:import)).to be_a(Import)
        expect(assigns(:import)).to be_persisted
        expect(assigns(:import).import_options.column_separator).to eq(',')
        expect(assigns(:import).import_options.quote_char).to eq("'")
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved import as @import' do
        invalid_attributes[:term_id] = term.id

        post :create, params: invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:import)).to be_a_new(Import)
      end

      it 'shows an encoding related error message' do
        invalid_attributes[:term_id] = term.id
        invalid_attributes[:import][:file] = Rack::Test::UploadedFile.new(prepare_static_test_file('import_data_invalid_encoding.csv'), 'text/csv')

        post :create, params: invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(flash[:alert]).to eq('Error with file encoding! UTF8-like is required.')
      end

      it 'shows an parsing related error message' do
        invalid_attributes[:term_id] = term.id
        invalid_attributes[:import][:file] = Rack::Test::UploadedFile.new(prepare_static_test_file('import_data_invalid_parsing.csv'), 'text/csv')

        post :create, params: invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(flash[:alert]).to eq('Error during parsing! Corrupt data detected.')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested import' do
        valid_attributes[:term_id] = term.id
        valid_attributes[:id] = import.id
        import.update(updated_at: 5.minutes.ago)

        expect do
          put :update, params: valid_attributes
          import.reload
        end.to change(import, :updated_at)

        expect(response).to redirect_to(results_term_import_path(term, import))
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
        delete :destroy, params: { term_id: term.id, id: import.id }
      end.to change(Import, :count).by(-1)

      expect(response).to redirect_to(new_term_import_path(term))
    end
  end

  describe 'GET file' do
    it 'sends a file' do
      expect(controller).to receive(:send_file).with(import.file.to_s) {
        # to prevent a 'missing template' error
        controller.head :ok
      }

      get :file, params: { term_id: term.id, id: import.id }

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET full_mapping_table' do
    it 'assigns the requested import as @import' do
      get :full_mapping_table, params: { term_id: term.id, id: import.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:import)).to eq(import)
      expect(assigns(:entries)).to eq(ImportService.new(import).values)
      expect(assigns(:column_count)).to eq(ImportService.new(import).column_count)
    end
  end

  describe 'GET results' do
    it 'assigns the requested import as @import' do
      get :results, params: { term_id: term.id, id: import.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:import)).to eq(import)
    end
  end
end
