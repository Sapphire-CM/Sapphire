require 'rails_helper'

RSpec.describe EvaluationsController, type: :controller do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryBot.create :term }
  let(:exercise) { FactoryBot.create :exercise, :with_ratings, term: term }
  let(:rating_group) { exercise.rating_groups.first }

  let(:submission) { FactoryBot.create_list(:submission, 3, exercise: exercise)[1] }
  let(:submission_evaluation) { submission.submission_evaluation }


  describe 'PUT update' do
    describe 'with valid params' do
      context 'with a FixedRating' do
        [Ratings::FixedPointsDeductionRating, Ratings::FixedPercentageDeductionRating, Ratings::PlagiarismRating].each do |type|
          [true, false].each do |checked|
            it 'updates the requested evaluation' do
              rating = FactoryBot.create rating_factory(type), rating_group: rating_group, type: type.to_s
              evaluation = submission_evaluation.evaluations.where(rating_id: rating.id).first
              evaluation.update! value: (checked ? 0 : 1)
              submission_evaluation.update! updated_at: 42.days.ago

              expect do
                put :update, params: { id: evaluation.id, evaluation: { value: (checked ? 1 : 0) } }, xhr: true

                submission_evaluation.reload
                evaluation.reload
              end.to change(submission_evaluation, :updated_at)

              expect(response).to have_http_status(:success)
              expect(assigns(:evaluation)).to eq(evaluation)
              expect(assigns(:submission)).to eq(submission)
              expect(assigns(:submission_evaluation)).to eq(submission_evaluation)
              expect(evaluation.value == 1).to eq(checked)
            end
          end
        end
      end

      context 'with a VariableRating' do
        [Ratings::VariablePointsDeductionRating, Ratings::VariablePercentageDeductionRating].each do |type|
          it 'updates the requested evaluation' do
            rating = FactoryBot.create rating_factory(type), rating_group: rating_group, type: type.to_s, min_value: -5, max_value: 0
            evaluation = submission_evaluation.evaluations.where(rating_id: rating.id).first
            submission_evaluation.update! updated_at: 42.days.ago

            expect do
              put :update, params: { id: evaluation.id, evaluation: { value: '-3' } }, xhr: true
              submission_evaluation.reload
              evaluation.reload
            end.to change(submission_evaluation, :updated_at)

            expect(response).to have_http_status(:success)
            expect(assigns(:evaluation)).to eq(evaluation)
            expect(assigns(:submission)).to eq(submission)
            expect(assigns(:submission_evaluation)).to eq(submission_evaluation)
            expect(evaluation.value).to eq(-3)
          end
        end
      end

      context 'as a tutor' do
        let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
        let(:tutor_registration) { FactoryBot.create(:term_registration, :tutor, term: term, tutorial_group: tutorial_group) }

        before :each do
          sign_in(tutor_registration.account)
        end

        [Ratings::FixedPointsDeductionRating, Ratings::FixedPercentageDeductionRating, Ratings::PlagiarismRating].each do |type|
          [true, false].each do |checked|
            it 'updates the requested evaluation' do
              rating = FactoryBot.create rating_factory(type), rating_group: rating_group
              evaluation = submission_evaluation.evaluations.where(rating_id: rating.id).first
              evaluation.update! value: (checked ? 0 : 1)
              submission_evaluation.update! updated_at: 42.days.ago

              expect do
                put :update, params: { id: evaluation.id, evaluation: { value: (checked ? 1 : 0) } }, xhr: true
                submission_evaluation.reload
                evaluation.reload
              end.to change(submission_evaluation, :updated_at)

              expect(response).to have_http_status(:success)
              expect(assigns(:evaluation)).to eq(evaluation)
              expect(assigns(:submission)).to eq(submission)
              expect(assigns(:submission_evaluation)).to eq(submission_evaluation)
              expect(evaluation.value == 1).to eq(checked)
            end
          end
        end
      end
    end

    describe 'with invalid params' do
      context 'with a VariableRating' do
        [Ratings::VariablePointsDeductionRating, Ratings::VariablePercentageDeductionRating].each do |type|
          it 'returns a JS containing an alert' do
            rating = FactoryBot.create rating_factory(type), rating_group: rating_group, type: type.to_s, min_value: -5, max_value: 0
            evaluation = submission_evaluation.evaluations.where(rating_id: rating.id).first
            submission_evaluation.update! updated_at: 42.days.ago

            expect do
              put :update, params: { id: evaluation.id, evaluation: { value: '42' } }, xhr: true
              submission_evaluation.reload
              evaluation.reload
            end.not_to change {evaluation.value}

            expect(response).to have_http_status(:success)
            expect(assigns(:evaluation)).to eq(evaluation)
            expect(assigns(:submission)).to eq(submission)
            expect(assigns(:submission_evaluation)).to eq(submission_evaluation)
            expect(response.body).to include("alert")
          end
        end
      end
    end
  end
end
