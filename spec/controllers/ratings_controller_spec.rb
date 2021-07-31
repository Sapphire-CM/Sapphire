require 'rails_helper'

RSpec.describe RatingsController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      rating: {
        title: 'Some Title',
        description: 'Some longer description text.',
        type: 'Ratings::FixedPointsDeductionRating',
        value: '-42',
      }
    }
  end

  let(:invalid_attributes) do
    {
      rating: {
        title: 'Some Existing Title',
        description: 'Some longer description text.',
        type: 'Ratings::FixedPointsDeductionRating',
      }
    }
  end

  let(:exercise) { FactoryBot.create :exercise }
  let(:rating_group) { FactoryBot.create :rating_group, exercise: exercise }
  let(:rating) { FactoryBot.create :fixed_points_deduction_rating, rating_group: rating_group }

  describe 'GET new' do
    it 'assigns a new rating as @rating' do
      get :new, params: { exercise_id: exercise.id, rating_group_id: rating_group.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(assigns(:rating)).to be_a_new(Rating)
      expect(assigns(:rating).rating_group).to eq(rating_group)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Rating' do
        valid_attributes[:exercise_id] = exercise.id
        valid_attributes[:rating_group_id] = rating_group.id

        expect do
          post :create, params: valid_attributes, xhr: true
        end.to change(Rating, :count).by(1)


        expect(response).to have_http_status(:success)
        expect(response).to render_template(:_insert_index_entry)
        expect(assigns(:rating)).to be_a(Rating)
        expect(assigns(:rating)).to be_persisted
        expect(assigns(:rating).rating_group).to eq(rating_group)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved rating as @rating' do
        invalid_attributes[:exercise_id] = exercise.id
        invalid_attributes[:rating_group_id] = rating_group.id

        post :create, params: invalid_attributes, xhr: true

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(response).not_to render_template(:_insert_index_entry)
        expect(assigns(:rating)).to be_a_new(Rating)
      end
    end

    describe 'without a type' do
      it 'shows an error' do
        invalid_attributes[:exercise_id] = exercise.id
        invalid_attributes[:rating_group_id] = rating_group.id
        invalid_attributes[:rating][:type] = nil

        expect do
          post :create, params: invalid_attributes, xhr: true
        end.to change(Rating, :count).by(0)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end
    end

    describe 'with invalid type' do
      it 'shows an error' do
        invalid_attributes[:exercise_id] = exercise.id
        invalid_attributes[:rating_group_id] = rating_group.id
        invalid_attributes[:rating][:type] = 'foo_bar'

        expect do
          post :create, params: invalid_attributes, xhr: true
        end.to change(Rating, :count).by(0)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET edit' do
    it 'assigns the requested term as @term' do
      get :edit, params: { exercise_id: exercise.id, rating_group_id: rating_group.id, id: rating.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(assigns(:rating)).to be_a(Rating)
      expect(assigns(:rating).id).to eq(rating.id)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested rating' do
        valid_attributes[:exercise_id] = exercise.id
        valid_attributes[:rating_group_id] = rating_group.id
        valid_attributes[:id] = rating.id

        put :update, params: valid_attributes, xhr: true

        rating.reload
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:_replace_index_entry)
        expect(assigns(:rating)).to be_a(Rating)
        expect(assigns(:rating).id).to eq(rating.id)
        expect(rating.description).to eq valid_attributes[:rating][:description]
      end
    end

    describe 'with invalid params' do
      it 'assigns the requested rating as @rating' do
        invalid_attributes[:exercise_id] = exercise.id
        invalid_attributes[:rating_group_id] = rating_group.id
        invalid_attributes[:id] = rating.id
        invalid_attributes[:rating][:value] = ''

        put :update, params: invalid_attributes, xhr: true

        rating.reload
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
        expect(assigns(:rating)).to be_a(Rating)
        expect(assigns(:rating).id).to eq(rating.id)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested rating' do
      rating.reload # trigger creation

      expect do
        delete :destroy, params: { exercise_id: exercise.id, rating_group_id: rating_group.id, id: rating.id }, xhr: true
      end.to change(Rating, :count).by(-1)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:_remove_index_entry)
    end
  end

  describe 'POST update_position' do
    it 'changes the row_order_position of the rating' do
      new_rating_group = FactoryBot.create :rating_group
      FactoryBot.create_list :fixed_points_deduction_rating, 4, rating_group: new_rating_group

      attributes = {
        exercise_id: exercise.id,
        rating_group_id: rating_group.id,
        id: rating.id,
        rating: {
          rating_group_id: new_rating_group.id,
          row_order_position: '2',
        }
      }

      expect do
        post :update_position, params: attributes, xhr: true
        rating.reload
      end.to change(rating, :row_order)

      expect(response).to have_http_status(:success)
      expect(response.body).to eq(update_position_exercise_rating_group_rating_path(exercise, new_rating_group, rating))
      expect(rating_group.ratings).not_to include rating
      expect(new_rating_group.ratings).to include rating
    end
  end
end
