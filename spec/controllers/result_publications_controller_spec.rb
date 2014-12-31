require 'rails_helper'

RSpec.describe ResultPublicationsController do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryGirl.create :term }
  let(:exercise) { FactoryGirl.create :exercise, term: term }
  let(:tutorial_groups) { FactoryGirl.create_list :tutorial_group, 4, term: term }

  describe 'GET index' do
    it 'assigns all result_publications as @result_publications' do
      get :index, exercise_id: exercise.id

      expect(assigns[:term]).to eq(term)
      expect(assigns[:exercise]).to eq(exercise)
      expect(assigns[:result_publications]).to match_array(exercise.result_publications)
    end
  end

  describe 'PUT update' do
    let(:url_params) { { exercise_id: exercise.id, id: exercise.result_publication_for(tutorial_groups.first) } }

    context 'publish' do
      it 'updates the publication status of a tutorial group' do
        put :update, url_params.merge(result_publication: { published: true })

        expect(exercise.result_published_for?(tutorial_groups.first)).to be_truthy
      end
    end

    context 'unpublish' do
      it 'shows a different flash message if the publication status is not updated' do
        put :update, url_params.merge(result_publication: { published: false })

        expect(flash[:notice]).not_to be_empty
      end
    end
  end
end
