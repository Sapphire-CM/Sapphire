require 'rails_helper'

RSpec.describe CoursesController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      course: {
        title: 'Some Title',
        description: 'Some longer description text.',
      }
    }
  end

  let(:invalid_attributes) do
    {
      course: {
        title: 'Some Existing Title',
        description: 'Some longer description text.',
      }
    }
  end

  let(:course) { FactoryGirl.create :course }

  describe 'GET index' do
    it 'assigns all courses as @courses' do
      FactoryGirl.create_list :course, 4

      get :index

      expect(response).to have_http_status(:success)
      expect(assigns(:courses)).to eq(Course.all)
    end
  end

  describe 'GET new' do
    it 'assigns a new course as @course' do
      get :new, xhr: true

      expect(response).to have_http_status(:success)
      expect(assigns(:course)).to be_a_new(Course)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Course' do
        expect do
          post :create, params: valid_attributes, xhr: true
        end.to change(Course, :count).by(1)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:create)
        expect(assigns(:course)).to be_a(Course)
        expect(assigns(:course)).to be_persisted
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved course as @course' do
        FactoryGirl.create :course, title: invalid_attributes[:course][:title]

        post :create, params: invalid_attributes, xhr: true

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:course)).to be_a_new(Course)
      end
    end
  end

  describe 'GET edit' do
    it 'assigns the requested course as @course' do
      get :edit, params: { id: course.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)

      expect(assigns(:course)).to eq(course)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested course' do
        valid_attributes[:id] = course.id

        put :update, params: valid_attributes, xhr: true

        course.reload
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:update)
        expect(assigns(:course)).to eq(course)
        expect(course.title).to eq valid_attributes[:course][:title]
        expect(course.description).to eq valid_attributes[:course][:description]
      end
    end

    describe 'with invalid params' do
      it 'assigns the requested course as @course' do
        FactoryGirl.create :course, title: invalid_attributes[:course][:title]
        invalid_attributes[:id] = course.id

        put :update, params: invalid_attributes, xhr: true

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
        expect(assigns(:course)).to eq(course)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested course and renders a JS template using XHR requests' do
      course.reload # trigger creation

      expect do
        delete :destroy, params: { id: course.id }, xhr: true
      end.to change(Course, :count).by(-1)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:destroy)
    end

    it 'destroys the requested course and redirects to the root path for HTML requests' do
      course.reload # trigger creation

      expect do
        delete :destroy, params: { id: course.id }
      end.to change(Course, :count).by(-1)

      expect(response).to redirect_to(root_path)
    end
  end
end
