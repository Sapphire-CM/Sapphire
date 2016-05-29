require 'rails_helper'

RSpec.describe ResultPublicationsController do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryGirl.create :term }
  let!(:exercise) { FactoryGirl.create :exercise, term: term }
  let!(:tutorial_groups) { FactoryGirl.create_list :tutorial_group, 4, term: term }

  describe 'GET index' do
    it 'assigns all result_publications as @result_publications' do
      get :index, exercise_id: exercise.id

      expect(assigns[:term]).to eq(term)
      expect(assigns[:exercise]).to eq(exercise)
      expect(assigns[:result_publications]).to match_array(exercise.result_publications)
    end
  end

  context 'mocked result publication service' do
    let(:mocked_result_publication_service) do
      service = double
      allow(service).to receive(:publish!)
      allow(service).to receive(:conceal!)
      allow(service).to receive(:publish_all!)
      allow(service).to receive(:conceal_all!)
      service
    end

    let(:result_publications) { exercise.result_publications }
    let(:result_publication) { result_publications.first }

    before :each do
      allow(ResultPublicationService).to receive(:new).with(current_account, exercise).and_return(mocked_result_publication_service)
    end

    context 'member actions' do
      let(:url_params) { { exercise_id: exercise.id, id: result_publication.id } }

      context 'PUT publish' do
        it 'updates the publication status of a tutorial group' do
          expect(mocked_result_publication_service).to receive(:publish!).with(result_publication)

          put :publish, url_params

          expect(flash[:notice]).not_to be_blank
          expect(response).to redirect_to exercise_result_publications_path(exercise)
        end
      end

      context 'PUT conceal' do
        it 'shows a different flash message if the publication status is not updated' do
          expect(mocked_result_publication_service).to receive(:conceal!).with(result_publication)

          put :conceal, url_params

          expect(flash[:notice]).not_to be_blank
          expect(response).to redirect_to exercise_result_publications_path(exercise)
        end
      end
    end

    context 'collection actions' do
      describe 'PUT publish_all' do
        it 'publishes all result publications' do
          expect(mocked_result_publication_service).to receive(:publish_all!)

          put :publish_all, exercise_id: exercise.id

          expect(flash[:notice]).not_to be_blank
          expect(response).to redirect_to exercise_result_publications_path(exercise)
        end
      end

      describe 'PUT conceal_all' do
        it 'conceals all result publications' do
          expect(mocked_result_publication_service).to receive(:conceal_all!)

          put :conceal_all, exercise_id: exercise.id

          expect(flash[:notice]).not_to be_blank
          expect(response).to redirect_to exercise_result_publications_path(exercise)
        end
      end
    end
  end
end
