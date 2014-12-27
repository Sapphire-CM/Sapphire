require 'rails_helper'

RSpec.describe RatingGroupsController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      rating_group: {
        title: 'Some Title',
        description: 'Some longer description text.',
        points: '42',
        min_points: '0',
        max_points: '50',
      }
    }
  end

  let(:invalid_attributes) do
    {
      rating_group: {
        title: 'Some Existing Title',
        description: 'Some longer description text.',
        points: '',
      }
    }
  end

  let(:exercise) { FactoryGirl.create :exercise, :with_ratings }
  let(:rating_group) { FactoryGirl.create :rating_group, exercise: exercise }

  describe 'GET index' do
    it 'assigns all rating_groups as @rating_groups' do
      FactoryGirl.create_list :rating_group, 4

      get :index, exercise_id: exercise.id

      expect(response).to have_http_status(:success)
      expect(assigns(:exercise)).to eq(exercise)
      expect(assigns(:rating_groups)).to match_array(exercise.rating_groups)
    end
  end

  describe 'GET new' do
    it 'assigns a new rating_group as @rating_group' do
      xhr :get, :new, exercise_id: exercise.id

      expect(response).to have_http_status(:success)
      expect(assigns(:rating_group)).to be_a_new(RatingGroup)
      expect(assigns(:rating_group).exercise).to eq(exercise)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new RatingGroup' do
        valid_attributes[:exercise_id] = exercise.id

        expect {
          xhr :post, :create, valid_attributes
        }.to change(RatingGroup, :count).by(1)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:_insert_index_entry)
        expect(assigns(:rating_group)).to be_a(RatingGroup)
        expect(assigns(:rating_group)).to be_persisted
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved rating_group as @rating_group' do
        invalid_attributes[:exercise_id] = exercise.id

        xhr :post, :create, invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(response).not_to render_template(:_insert_index_entry)
        expect(assigns(:rating_group)).to be_a_new(RatingGroup)
      end
    end
  end

  describe 'GET edit' do
    it 'assigns the requested rating_group as @rating_group' do
      xhr :get, :edit, exercise_id: exercise.id, id: rating_group.id

      expect(response).to have_http_status(:success)
      expect(assigns(:rating_group)).to eq(rating_group)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested rating_group' do
        valid_attributes[:exercise_id] = exercise.id
        valid_attributes[:id] = rating_group.id

        xhr :put, :update, valid_attributes

        rating_group.reload
        expect(response).to have_http_status(:success)
        expect(assigns(:rating_group)).to eq(rating_group)
        expect(rating_group.title).to eq(valid_attributes[:rating_group][:title])
        expect(rating_group.description).to eq(valid_attributes[:rating_group][:description])
        expect(rating_group.points).to eq(valid_attributes[:rating_group][:points].to_i)
      end
    end

    describe 'with invalid params' do
      it 'assigns the requested rating_group as @rating_group' do
        invalid_attributes[:exercise_id] = exercise.id
        invalid_attributes[:id] = rating_group.id

        xhr :put, :update, invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
        expect(assigns(:rating_group)).to eq(rating_group)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested rating_group' do
      rating_group.reload # trigger creation

      expect {
        xhr :delete, :destroy, exercise_id: exercise.id, id: rating_group.id
      }.to change(RatingGroup, :count).by(-1)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:_remove_index_entry)
    end
  end
end
