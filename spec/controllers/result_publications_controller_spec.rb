require 'rails_helper'

RSpec.describe ResultPublicationsController do
#  render_views
#  include_context 'active_admin_session_context'

  it 'needs to be implemented'

  before :each do
    sign_in(user)
  end

  let(:course) { create(:course) }
  let(:term) { create(:term, course: course) }
  let(:tutorial_groups) { create_list(:tutorial_group, 6, term: term)}
  let(:exercise) {create(:exercise, term: term)}

  context "GET #index" do
    context "as an admin" do
      let(:user) {create(:account, :admin)}

      it "should assign @term" do
        get :index, exercise_id: exercise.id
        expect(assigns[:term]).to eq(term)
      end

      it "should assign @exercise" do
        get :index, exercise_id: exercise.id
        expect(assigns[:exercise]).to eq(exercise)
      end

      it "should assign @result_publications" do
        get :index, exercise_id: exercise.id

        expect(assigns[:result_publications].map(&:id)).to eq(exercise.result_publications.map(&:id))
      end
    end
  end

  context "PATCH #update" do
    context "as an admin" do
      let(:user) {create(:account, :admin)}
      let(:url_params) { {exercise_id: exercise.id, id: exercise.result_publication_for(tutorial_groups.first)} }

      it "should update the publication status of a tutorial group" do
        patch :update, url_params.merge({result_publication: {published: true}})

        expect(exercise.result_published_for?(tutorial_groups.first)).to be_truthy
      end

      it "should present a different flash message if the publication status is not updated" do
        patch :update, url_params.merge({result_publication: {published: false}})

        expect(flash[:notice]).not_to be_empty
      end
    end
  end
end
