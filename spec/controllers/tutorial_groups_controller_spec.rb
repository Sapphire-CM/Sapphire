require 'rails_helper'

RSpec.describe TutorialGroupsController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      tutorial_group: {
        title: 'Some Title',
        description: 'Some longer description text.',
      }
    }
  end

  let(:invalid_attributes) do
    {
      tutorial_group: {
        title: 'Some Existing Title',
        description: 'Some longer description text.',
      }
    }
  end

  let(:term) { FactoryBot.create :term }

  let(:tutorial_group) { FactoryBot.create :tutorial_group, term: term }

  describe 'GET index' do
    it 'assigns all tutorial_groups as @tutorial_groups' do
      FactoryBot.create_list :tutorial_group, 4, term: term

      get :index, params: { term_id: term.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:tutorial_groups)).to match_array(term.tutorial_groups)
    end
  end

  describe 'GET show' do
    it 'assigns the requested tutorial_group as @tutorial_group' do
      get :show, params: { term_id: term.id, id: tutorial_group.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:tutorial_group)).to eq(tutorial_group)
    end
  end

  describe 'GET new' do
    it 'assigns a new tutorial_group as @tutorial_group' do
      get :new, params: { term_id: term.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(assigns(:tutorial_group)).to be_a_new(TutorialGroup)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new TutorialGroup' do
        valid_attributes[:term_id] = term.id

        expect do
          post :create, params: valid_attributes
        end.to change(TutorialGroup, :count).by(1)

        expect(response).to redirect_to(term_tutorial_group_path(term, assigns(:tutorial_group)))
        expect(assigns(:tutorial_group)).to be_a(TutorialGroup)
        expect(assigns(:tutorial_group)).to be_persisted
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved tutorial_group as @tutorial_group' do
        FactoryBot.create :tutorial_group, term: term, title: invalid_attributes[:tutorial_group][:title]
        invalid_attributes[:term_id] = term.id

        post :create, params: invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:tutorial_group)).to be_a_new(TutorialGroup)
      end
    end
  end

  describe 'GET edit' do
    it 'assigns the requested tutorial_group as @tutorial_group' do
      get :edit, params: { term_id: term.id, id: tutorial_group.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:tutorial_group)).to eq(tutorial_group)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested tutorial_group' do
        valid_attributes[:term_id] = term.id
        valid_attributes[:id] = tutorial_group.id

        put :update, params: valid_attributes

        tutorial_group.reload
        expect(response).to redirect_to(term_tutorial_group_path(term, tutorial_group))
        expect(assigns(:tutorial_group)).to eq(tutorial_group)
        expect(tutorial_group.title).to eq valid_attributes[:tutorial_group][:title]
        expect(tutorial_group.description).to eq valid_attributes[:tutorial_group][:description]
      end
    end

    describe 'with invalid params' do
      it 'assigns the requested tutorial_group as @tutorial_group' do
        FactoryBot.create :tutorial_group, term: term, title: invalid_attributes[:tutorial_group][:title]
        invalid_attributes[:term_id] = term.id
        invalid_attributes[:id] = tutorial_group.id

        put :update, params: invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
        expect(assigns(:tutorial_group)).to eq(tutorial_group)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested tutorial_group' do
      tutorial_group.reload # trigger creation

      expect do
        delete :destroy, params: { term_id: term.id, id: tutorial_group.id }
      end.to change(TutorialGroup, :count).by(-1)

      expect(response).to redirect_to(term_path(term))
    end
  end

  describe 'GET points_overview' do
    it 'shows the points overview' do
      get :points_overview, params: { term_id: term.id, id: tutorial_group.id }

      expect(assigns(:tutorial_group)).to eq(tutorial_group)
    end
  end
end
