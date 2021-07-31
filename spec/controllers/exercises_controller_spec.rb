require 'rails_helper'

RSpec.describe ExercisesController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      exercise: {
        title: 'Some Title',
        description: 'Some longer description text.',
      }
    }
  end

  let(:invalid_attributes) do
    {
      exercise: {
        title: 'Some Existing Title',
        description: 'Some longer description text.',
      }
    }
  end

  let(:term) { FactoryGirl.create :term }

  let(:exercise) { FactoryGirl.create :exercise, term: term }

  describe 'GET index' do
    it 'assigns all exercises as @exercises' do
      FactoryGirl.create_list :exercise, 4, term: term

      get :index, params: { term_id: term.id }

      term.reload
      expect(response).to have_http_status(:success)
      expect(assigns(:exercises)).to match_array(term.exercises)
    end
  end

  describe 'GET new' do
    it 'assigns a new exercise as @exercise' do
      get :new, params: { term_id: term.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(assigns(:exercise)).to be_a_new(Exercise)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Exercise' do
        valid_attributes[:exercise][:term_id] = term.id

        expect do
          post :create, params: valid_attributes
        end.to change(Exercise, :count).by(1)

        expect(response).to redirect_to(exercise_path(Exercise.last))
        expect(assigns(:exercise)).to be_a(Exercise)
        expect(assigns(:exercise)).to be_persisted
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved exercise as @exercise' do
        FactoryGirl.create :exercise, term: term, title: invalid_attributes[:exercise][:title]
        invalid_attributes[:exercise][:term_id] = term.id

        post :create, params: invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:exercise)).to be_a_new(Exercise)
      end
    end
  end

  describe 'GET edit' do
    it 'assigns the requested exercise as @exercise' do
      get :edit, params: { id: exercise.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:exercise)).to eq(exercise)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested exercise' do
        valid_attributes[:id] = exercise.id

        put :update, params: valid_attributes

        exercise.reload
        expect(response).to redirect_to(exercise_path(exercise))
        expect(assigns(:exercise)).to eq(exercise)
        expect(exercise.title).to eq valid_attributes[:exercise][:title]
        expect(exercise.description).to eq valid_attributes[:exercise][:description]
      end
    end

    describe 'with invalid params' do
      it 'assigns the requested exercise as @exercise' do
        FactoryGirl.create :exercise, term: term, title: invalid_attributes[:exercise][:title]
        invalid_attributes[:id] = exercise.id

        put :update, params: invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
        expect(assigns(:exercise)).to eq(exercise)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested exercise' do
      exercise.reload # trigger creation

      expect do
        delete :destroy, params: { id: exercise.id }, xhr: true
      end.to change(Exercise, :count).by(-1)

      expect(response).to redirect_to(term_exercises_path(term))
    end
  end
end
