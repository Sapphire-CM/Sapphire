require 'rails_helper'
require_relative 'behaviours/comment_behaviour'

RSpec.describe SubmissionEvaluations::InternalNotesController, type: :controller do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryGirl.create :term }
  let(:exercise) { FactoryGirl.create :exercise, :with_ratings, term: term }

  let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }
  let(:commentable) { submission.submission_evaluation }

  describe 'GET index' do
    it 'assigns the commentable as @commentable' do
      xhr :get, :index, submission_evaluation_id: commentable.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:commentable)).to eq(commentable)
    end
  end

  it_behaves_like 'a comment' do

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

    let(:comment) { FactoryGirl.create :notes_comment }
  end
end
