require 'rails_helper'
require_relative 'behaviours/comment_behaviour'

RSpec.describe SubmissionEvaluations::InternalNotesController, type: :controller do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryBot.create :term }
  let(:exercise) { FactoryBot.create :exercise, :with_ratings, term: term }

  let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
  let(:commentable) { submission.submission_evaluation }

  describe 'GET index' do
    it 'assigns the commentable as @commentable' do
      get :index, params: { submission_evaluation_id: commentable.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:commentable)).to eq(commentable)
    end
  end

  it_behaves_like 'a comment controller' do

    let(:comment_with_content) do
      {
        comment: {
          content: "Some internal commment content",
          name: "internal_notes"
        },
        submission_evaluation_id: commentable.id,
        term: :term
      }
    end

    let(:comment_without_content) do
      {
        comment: {
          content: nil
        },
        submission_evaluation_id: commentable.id,
        term: :term
      }
    end

    let(:comment) { FactoryBot.create :notes_comment }
  end
end
