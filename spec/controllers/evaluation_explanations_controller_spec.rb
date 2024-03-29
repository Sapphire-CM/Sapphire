require 'rails_helper'
require_relative 'behaviours/comment_behaviour'

RSpec.describe Evaluations::ExplanationsController, type: :controller do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryBot.create :term }
  let(:exercise) { FactoryBot.create :exercise, :with_ratings, term: term }
  let(:rating_group) { exercise.rating_groups.first }

  let(:submission) { FactoryBot.create(:submission, exercise: exercise) }
  let(:submission_evaluation) { submission.submission_evaluation }
  let(:evaluation) { submission_evaluation.evaluations.first }

  let(:commentable) { evaluation.becomes(Evaluation) }

  describe 'GET index' do
    it 'assigns the commentable as @commentable' do
      get :index, params: { evaluation_id: commentable.id }, xhr: true

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:commentable)).to be_a(Evaluation)
    end
  end

  it_behaves_like 'a comment controller' do
      let(:comment_with_content) do
      {
        comment: {
          content: "Some commment content",
          name: "explanations"
        },
        evaluation_id: commentable.id,
        term: :term
      }
    end

    let(:comment_without_content) do
      {
        comment: {
          content: nil
        },
        evaluation_id: commentable.id,
        term: :term
      }
    end

    let(:comment) { FactoryBot.create :explanations_comment }
  end
end
