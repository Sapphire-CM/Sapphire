require 'rails_helper'

RSpec.describe Import::StudentImportsController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      import_student_import: {
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
      import_student_import: {
        term_id: term.id,
        file: '',
      }
    }
  end

  let(:term) { FactoryGirl.create :term }
  let(:student_import) { FactoryGirl.create :student_import, term: term }

  describe 'GET show' do
    it 'assigns the requested student_import as @student_import' do
      get :show, id: student_import.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:student_import)).to eq(student_import)
      expect(assigns(:student_import)).to be_decorated
    end
  end

  describe 'GET new' do
    it 'assigns a new student_import as @student_import' do
      get :new, term_id: term.id

      expect(response).to have_http_status(:success)
      expect(assigns(:student_import)).to be_a_new(Import::StudentImport)
      expect(assigns(:student_imports)).to eq(term.student_imports)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new StudentImport' do
        expect do
          post :create, valid_attributes
        end.to change(Import::StudentImport, :count).by(1)

        expect(response).to redirect_to(import_student_import_path(assigns(:student_import)))
        expect(assigns(:student_import)).to be_a(Import::StudentImport)
        expect(assigns(:student_import)).to be_persisted
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved student_import as @student_import' do
        post :create, invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:student_import)).to be_a_new(Import::StudentImport)
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested student_import' do
        valid_attributes[:id] = student_import.id

        expect {
          put :update, valid_attributes
          student_import.reload
        }.to change(student_import, :updated_at)

        expect(response).to redirect_to(results_import_student_import_path(student_import))
        expect(student_import.running?).to eq(true)
      end
    end

    describe 'with invalid params' do
      # can not happen
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested student_import' do
      student_import.reload # trigger creation

      expect do
        delete :destroy, id: student_import.id
      end.to change(Import::StudentImport, :count).by(-1)

      expect(response).to redirect_to(new_import_student_import_path(term_id: term.id))
    end
  end

  describe 'GET full_mapping_table' do
    it 'assigns the requested student_import as @student_import' do
      xhr :get, :full_mapping_table, id: student_import.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:student_import)).to eq(student_import)
      expect(assigns(:entries)).to eq(student_import.values)
      expect(assigns(:column_count)).to eq(student_import.column_count)
    end
  end

  describe 'GET results' do
    it 'assigns the requested student_import as @student_import' do
      get :results, id: student_import.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:student_import)).to eq(student_import)
    end
  end
end
