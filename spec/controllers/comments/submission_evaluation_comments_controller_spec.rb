require 'rails_helper'

RSpec.describe SubmissionEvaluations::CommentsController, type: :controller do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryGirl.create :term }
  let(:exercise) { FactoryGirl.create :exercise, :with_ratings, term: term }
  let(:rating_group) { exercise.rating_groups.first }

  let(:submission) { FactoryGirl.create_list(:submission, 3, exercise: exercise)[1] }
  let(:submission_evaluation) { submission.submission_evaluation }

  let(:comment_with_content) do 
    {
      comment: {
        content: "Some commment content"
      },
      submission_evaluation_id: submission_evaluation.id,
      term: :term
    }
  end

  let(:comment_without_content) do 
    {
      comment: {
        content: nil
      },
      submission_evaluation_id: submission_evaluation.id,
      term: :term
    }
  end

  let(:comment) { FactoryGirl.create :comment, account: current_account, commentable: submission_evaluation }

  describe 'GET index' do
    it 'assigns the submission evaluation as commentable' do
      xhr :get, :index, submission_evaluation_id: submission_evaluation.id
      
      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:commentable)).to eq(submission_evaluation)
    end
  end

  describe 'POST create' do
    describe 'with content' do 
      it 'creates a new comment' do
        expect do 
          xhr :post, :create, comment_with_content
        end.to change(Comment, :count).by(1)

        expect(response).to have_http_status(:success)
      end
    end

    describe 'without content' do 
      it 'does not create a new comment' do
        expect do 
          xhr :post, :create, comment_without_content
        end.to_not change(Comment, :count)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
      end
    end
  end

  describe 'GET edit' do
    it 'responds with edit form' do
      xhr :get, :edit, id: comment.id, submission_evaluation_id: submission_evaluation.id

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:edit)
    end
  end

  describe 'GET show' do
    it 'responds with comment show' do
      xhr :get, :show, id: comment.id, submission_evaluation_id: submission_evaluation.id

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
    end
  end

  describe 'PATCH update' do
    describe 'with content' do
      it 'responds with comment show' do
        xhr :patch, :update, id: comment.id, submission_evaluation_id: submission_evaluation.id, comment: { content: "lorem" }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:show)
      end
    end

    describe 'without content' do
      it 'responds with edit form' do
        xhr :patch, :update, id: comment.id, submission_evaluation_id: submission_evaluation.id, comment: { content: "" }

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroy the requested comment' do
      comment.reload

      expect do 
        xhr :delete, :destroy, id: comment.id, submission_evaluation_id: submission_evaluation.id
      end.to change(Comment, :count).by(-1)

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:destroy)
    end
  end
end

