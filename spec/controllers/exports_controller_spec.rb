require 'rails_helper'

RSpec.describe ExportsController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      export: {
        foo: 'bar',
        propbase_path: 'tmp/foobar.txt',
        summary: '1',
      }
    }
  end

  let(:invalid_attributes) do
    {
      export: {
        foo: 'bar',
      }
    }
  end

  let(:term) { FactoryGirl.create :term }
  let(:export) { FactoryGirl.create :export, term: term }

  describe 'GET index' do
    it 'assigns all exports as @exports' do
      FactoryGirl.create_list :export, 4, term: term

      get :index, term_id: term.id

      expect(response).to have_http_status(:success)
      expect(assigns(:exports)).to match_array(term.exports)
    end
  end

  describe 'GET new' do
    context 'without a type' do
      it 'doesn\'t assign @export' do
        get :new, term_id: term.id

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:_export_type_selector)
        expect(assigns(:export)).to be_nil
      end
    end

    context 'with invalid type' do
      it 'assigns a new export as @export' do
        get :new, term_id: term.id, type: 'foobar'

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:_export_type_selector)
        expect(assigns(:export)).to be_nil
      end
    end

    Export.types.each do |type|
      context "with valid type #{type}" do
        let(:mocked_export) { Export.new_from_type(type) }

        it 'assigns a new export as @export' do
          get :new, term_id: term.id, type: type

          expect(response).to have_http_status(:success)
          expect(assigns(:export)).to be_a_new(Export)
          expect(assigns(:export).type).to eq("Exports::#{type.camelize}_export".camelize)
          expect(assigns(:export).term).to eq(term)
        end

        it 'calls #set_default_values! on new exports' do
          expect(Export).to receive(:new_from_type).with(type).and_return(mocked_export)
          expect(mocked_export).to receive(:set_default_values!).and_call_original

          get :new, term_id: term.id, type: type
        end
      end
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      context 'without a type' do
        it 'does not create a new Export' do
          valid_attributes[:term_id] = term.id

          expect do
            post :create, valid_attributes
          end.not_to change(Export, :count)

          expect(response).to redirect_to(new_term_export_path(term))
        end
      end

      context 'with invalid type' do
        it 'does not create a new Export' do
          valid_attributes[:term_id] = term.id
          valid_attributes[:type] = 'foobar'

          expect do
            post :create, valid_attributes
          end.not_to change(Export, :count)

          expect(response).to redirect_to(new_term_export_path(term))
        end
      end

      Export.types.each do |type|
        context "with type #{type}" do
          it 'creates a new Export' do
            valid_attributes[:term_id] = term.id
            valid_attributes[:type] = type

            Export.class_from_type(type).properties.each do |property|
              valid_attributes[:export][property] = property if valid_attributes[:export][property].blank?
            end

            expect do
              post :create, valid_attributes
            end.to change(Export, :count).by(1)

            expect(response).to redirect_to(term_exports_path(term))
            expect(assigns(:export)).to be_a(Export)
            expect(assigns(:export)).to be_persisted
          end
        end
      end
    end

    context 'SubmissionExport' do
      describe 'with invalid params' do
        it 'assigns a newly created but unsaved export as @export' do
          invalid_attributes[:term_id] = term.id
          invalid_attributes[:type] = 'submission'

          expect do
            post :create, invalid_attributes
          end.not_to change(Exports::SubmissionExport, :count)

          expect(response).to have_http_status(:success)
          expect(response).to render_template(:new)
          expect(assigns(:export)).to be_a_new(Exports::SubmissionExport)
          expect(assigns(:export).term).to eq(term)
        end
      end
    end

    context 'GradingExport' do
      describe 'with invalid params' do
        it 'assigns a newly created but unsaved export as @export' do
          invalid_attributes[:term_id] = term.id
          invalid_attributes[:type] = 'grading'

          expect do
            post :create, invalid_attributes
          end.not_to change(Exports::GradingExport, :count)

          expect(response).to have_http_status(:success)
          expect(response).to render_template(:new)
          expect(assigns(:export)).to be_a_new(Exports::GradingExport)
          expect(assigns(:export).term).to eq(term)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested export' do
      export.reload # trigger creation

      expect do
        delete :destroy, term_id: term.id, id: export.id
      end.to change(Export, :count).by(-1)

      expect(response).to redirect_to(term_exports_path(term))
    end
  end

  describe 'GET download' do
    it 'sends a file' do
      export.update! status: :finished, file: Tempfile.new('foobar.txt', File.join(Rails.root, 'tmp'))

      expect(controller).to receive(:send_file).with(export.file.to_s) {
        # to prevent a 'missing template' error
        controller.render nothing: true
      }

      get :download, term_id: term.id, id: export.id

      expect(response).to have_http_status(:success)
    end

    it 'redirects on missing or unfinished export file' do
      get :download, term_id: term.id, id: export.id

      expect(response).to redirect_to(term_exports_path(term))
    end
  end
end
