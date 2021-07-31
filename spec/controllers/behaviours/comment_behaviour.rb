require 'rails_helper'

RSpec.shared_examples 'a comment controller' do
  render_views
  include_context 'active_admin_session_context'

  let(:commentable_id) { (commentable.class.name.underscore + '_id') }

  describe 'POST create' do
    describe 'with content' do
      it 'creates a new comment' do
        expect do
          post :create, params: comment_with_content, xhr: true
        end.to change(Comment, :count).by(1)

        expect(response).to have_http_status(:success)
      end
    end

    describe 'without content' do
      it 'does not create a new comment' do
        expect do
          post :create, params: comment_without_content, xhr: true
        end.to_not change(Comment, :count)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
      end
    end
  end

  describe 'GET edit' do
    it 'responds with edit form' do
      get :edit, params: { id: comment.id, commentable_id.to_sym => commentable.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
    end
  end

  describe 'GET show' do
    it 'responds with comment show' do
      get :show, params: { id: comment.id, commentable_id.to_sym => commentable.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
    end
  end

  describe 'PATCH update' do
    describe 'with content' do
      it 'responds with comment show' do
        patch :update, params: { id: comment.id, commentable_id.to_sym => commentable.id, comment: { content: "lorem" } }, xhr: true

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:update)
      end
    end

    describe 'without content' do
      it 'responds with edit form' do
        patch :update, params: { id: comment.id, commentable_id.to_sym => commentable.id, comment: { content: "" } }, xhr: true

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroy the requested comment' do
      comment.reload

      expect do
        delete :destroy, params: { id: comment.id, commentable_id.to_sym => commentable.id }, xhr: true
      end.to change(Comment, :count).by(-1)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:destroy)
    end
  end
end
