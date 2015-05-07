require 'rails_helper'

RSpec.describe SingleEvaluationsController do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryGirl.create :term }
  let(:exercise) { FactoryGirl.create :exercise, :with_ratings, term: term }
  let(:rating_group) { exercise.rating_groups.first }

  let(:submission) { FactoryGirl.create_list(:submission, 3, exercise: exercise)[1] }
  let(:submission_evaluation) { submission.submission_evaluation }

  describe 'GET show' do
    it 'assigns the requested submission as @submission' do
      get :show, id: submission.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term)).to eq(term)
      expect(assigns(:exercise)).to eq(exercise)
      expect(assigns(:submission)).to eq(submission)
      expect(assigns(:previous_submission)).to be_a(Submission) if assigns(:previous_submission)
      expect(assigns(:next_submission)).to be_a(Submission) if assigns(:next_submission)
    end

    context 'as a tutor' do
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let(:tutor_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, tutorial_group: tutorial_group) }

      it 'returns a successful response' do
        sign_in(tutor_registration.account)

        get :show, id: submission.id

        expect(response).to have_http_status(:success)
      end

      it 'returns a successful response when showing ascii encoded files' do
        FactoryGirl.create(:submission_asset, submission: submission, file: prepare_static_test_file('submission_asset_iso_latin.txt', open: true))

        sign_in(tutor_registration.account)
        get :show, id: submission.id
        expect(response).to have_http_status(:success)
        expect(response.body).to have_content('Submission containing special chars')
      end

    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      context 'with a BinaryRating' do
        [BinaryNumberRating, BinaryPercentRating, PlagiarismRating].each do |type|
          [true, false].each do |checked|
            it 'updates the requested evaluation' do
              rating = FactoryGirl.create :rating, rating_group: rating_group, type: type.to_s
              evaluation = submission_evaluation.evaluations.where(rating_id: rating.id).first
              evaluation.update! value: (checked ? 0 : 1)
              submission_evaluation.update! updated_at: 42.days.ago

              expect do
                xhr :put, :update, id: evaluation.id
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

      context 'with a ValueRating' do
        [ValueNumberRating, ValuePercentRating].each do |type|
          it 'updates the requested evaluation' do
            rating = FactoryGirl.create :rating, rating_group: rating_group, type: type.to_s, max_value: 50
            evaluation = submission_evaluation.evaluations.where(rating_id: rating.id).first
            submission_evaluation.update! updated_at: 42.days.ago

            expect do
              xhr :put, :update, id: evaluation.id, evaluation: { value: '42' }
              submission_evaluation.reload
              evaluation.reload
            end.to change(submission_evaluation, :updated_at)

            expect(response).to have_http_status(:success)
            expect(assigns(:evaluation)).to eq(evaluation)
            expect(assigns(:submission)).to eq(submission)
            expect(assigns(:submission_evaluation)).to eq(submission_evaluation)
            expect(evaluation.value).to eq(42)
          end
        end
      end

      context 'as a tutor' do
        let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
        let(:tutor_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, tutorial_group: tutorial_group) }

        before :each do
          sign_in(tutor_registration.account)
        end

        [BinaryNumberRating, BinaryPercentRating, PlagiarismRating].each do |type|
          [true, false].each do |checked|
            it 'updates the requested evaluation' do
              rating = FactoryGirl.create :rating, rating_group: rating_group, type: type.to_s
              evaluation = submission_evaluation.evaluations.where(rating_id: rating.id).first
              evaluation.update! value: (checked ? 0 : 1)
              submission_evaluation.update! updated_at: 42.days.ago

              expect do
                xhr :put, :update, id: evaluation.id
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
      # can not happen
    end
  end
end
