require 'rails_helper'

RSpec.describe TermsController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      term: {
        title: 'Some Title',
        description: 'Some longer description text.',
      }
    }
  end

  let(:invalid_attributes) do
    {
      term: {
        title: 'Some Existing Title',
        description: 'Some longer description text.',
      }
    }
  end

  let(:course) { FactoryGirl.create :course }

  let(:term) { FactoryGirl.create :term, course: course }

  describe 'GET show' do
    it 'assigns the requested term as @term' do
      xhr :get, :show, id: term.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
    end
  end

  describe 'GET new' do
    it 'assigns a new term as @term' do
      xhr :get, :new, course_id: course.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to be_a_new(Term)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Term' do
        valid_attributes[:term][:course_id] = course.id

        expect do
          xhr :post, :create, valid_attributes
        end.to change(Term, :count).by(1)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:_insert_index_entry)
        expect(assigns(:term)).to be_a(Term)
        expect(assigns(:term)).to be_persisted
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved term as @term' do
        FactoryGirl.create :term, course: course, title: invalid_attributes[:term][:title]
        invalid_attributes[:term][:course_id] = course.id

        xhr :post, :create, invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(response).not_to render_template(:_insert_index_entry)
        expect(assigns(:term)).to be_a_new(TermNew)
      end
    end
  end

  describe 'GET edit' do
    it 'assigns the requested term as @term' do
      get :edit, id: term.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested term' do
        valid_attributes[:id] = term.id

        put :update, valid_attributes

        term.reload
        expect(response).to redirect_to(term_path(term))
        expect(assigns(:term)).to eq(term)
        expect(term.title).to eq valid_attributes[:term][:title]
        expect(term.description).to eq valid_attributes[:term][:description]
      end
    end

    describe 'with invalid params' do
      it 'assigns the requested term as @term' do
        FactoryGirl.create :term, course: course, title: invalid_attributes[:term][:title]
        invalid_attributes[:id] = term.id

        put :update, invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
        expect(assigns(:term)).to eq(term)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested term' do
      term.reload # trigger creation

      expect do
        xhr :delete, :destroy, id: term.id
      end.to change(Term, :count).by(-1)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET points_overview' do
    it 'shows the points overview' do
      get :points_overview, id: term.id

      expect(assigns(:grading_scale)).to be_a(GradingScaleService)
    end
  end
end
