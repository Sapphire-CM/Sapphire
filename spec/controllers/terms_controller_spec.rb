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

  let(:course) { FactoryBot.create :course }

  let(:term) { FactoryBot.create :term, course: course }

  describe 'GET show' do
    it 'assigns the requested term as @term' do
      get :show, params: { id: term.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(response).to render_template(:_sidebar)
      expect(response).to render_template(:show)
    end

    describe 'copying values from previous term' do
      before :each do
        term.preparing!
      end

      it 'hides the navigation sidebar' do
        get :show, params: { id: term.id }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
        expect(response).not_to render_template(:sidebar)
      end

      it 'hides the main navigation items' do
        get :show, params: { id: term.id }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
        expect(response.body).not_to have_content('Exercises')
      end

      it 'shows a stand by message' do
        get :show, params: { id: term.id }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
        expect(response.body).to have_content('stand by')
      end
    end
  end

  describe 'GET new' do
    it 'assigns a new term as @term' do
      get :new, params: { course_id: course.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:new)

      expect(assigns(:term)).to be_a_new(Term)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Term' do
        valid_attributes[:term][:course_id] = course.id

        expect do
          post :create, params: valid_attributes, xhr: true
        end.to change(Term, :count).by(1)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:create)
        expect(assigns(:term)).to be_a(Term)
        expect(assigns(:term)).to be_persisted
        expect(assigns(:term)).to be_ready
      end

      it 'creates and copies a new Term in the background' do
        source_term = FactoryBot.create(:term, course: course)
        FactoryBot.create_list :exercise, 4, :with_ratings, term: source_term

        valid_attributes[:term][:course_id] = course.id
        valid_attributes[:term][:source_term_id] = source_term.id
        valid_attributes[:term][:copy_lecturer] = '1'
        valid_attributes[:term][:copy_grading_scale] = '1'
        valid_attributes[:term][:copy_exercises] = '1'

        expect(TermCopyJob).to receive(:perform_later).with(kind_of(Numeric), source_term.id.to_s, anything)

        expect do
          post :create, params: valid_attributes, xhr: true
        end.to change(Term, :count).by(1)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:create)
        expect(assigns(:term)).to be_a(Term)
        expect(assigns(:term)).to be_persisted
        expect(assigns(:term)).not_to be_ready
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved term as @term' do
        FactoryBot.create :term, course: course, title: invalid_attributes[:term][:title]
        invalid_attributes[:term][:course_id] = course.id

        post :create, params: invalid_attributes, xhr: true

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:term)).to be_a_new(TermNew)
      end
    end
  end

  describe 'GET edit' do
    it 'assigns the requested term as @term' do
      get :edit, params: { id: term.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
      expect(assigns(:term)).to eq(term)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested term' do
        valid_attributes[:id] = term.id

        put :update, params: valid_attributes

        term.reload
        expect(response).to redirect_to(term_path(term))
        expect(assigns(:term)).to eq(term)
        expect(term.title).to eq valid_attributes[:term][:title]
        expect(term.description).to eq valid_attributes[:term][:description]
      end
    end

    describe 'with invalid params' do
      it 'assigns the requested term as @term' do
        FactoryBot.create :term, course: course, title: invalid_attributes[:term][:title]
        invalid_attributes[:id] = term.id

        put :update, params: invalid_attributes

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
        delete :destroy, params: { id: term.id }, xhr: true
      end.to change(Term, :count).by(-1)

      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET points_overview' do
    it 'shows the points overview' do
      get :points_overview, params: { id: term.id }

      expect(assigns(:grading_scale_service)).to be_a(GradingScaleService)
      expect(response).to render_template(:points_overview)
    end
  end
end
