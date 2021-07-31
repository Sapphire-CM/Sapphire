require 'rails_helper'

RSpec.describe StudentsController do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryGirl.create :term }

  describe 'GET index' do
    let!(:students) { FactoryGirl.create_list :term_registration, 4, :student, term: term }
    let!(:tutors) { FactoryGirl.create_list :term_registration, 4, :tutor, term: term }
    let!(:lecturers) { FactoryGirl.create_list :term_registration, 4, :lecturer, term: term }

    it 'lists all registered students' do
      get :index, params: { term_id: term.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:term_registrations)).to match_array(term.term_registrations.students)
      expect(assigns(:term_registrations)).to include(*students)
      expect(assigns(:term_registrations)).not_to include(*tutors)
      expect(assigns(:term_registrations)).not_to include(*lecturers)
      expect(assigns(:grading_scale_service)).to be_a(GradingScaleService)
    end

    context 'as a tutor' do
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let!(:tutor_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, tutorial_group: tutorial_group) }

      before :each do
        account = tutor_registration.account
        sign_in account
      end

      it 'returns a successful response' do
        get :index, params: { term_id: term.id }

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET show' do
    let(:tutorial_group) { create(:tutorial_group, term: term) }
    let(:term_registration) { create(:term_registration, :student, term: term, tutorial_group: tutorial_group) }
    let(:student_group) { create(:student_group, tutorial_group: tutorial_group) }

    it 'assigns @term_review' do
      get :show, params: { term_id: term.id, id: term_registration.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:term_review)).to be_a(GradingReview::TermReview)
      expect(assigns(:term_review).term_registration).to eq(term_registration)
    end

    context 'as a tutor' do
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let!(:tutor_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, tutorial_group: tutorial_group) }

      before :each do
        account = tutor_registration.account
        sign_in account
      end

      it 'returns a successful response' do
        get :show, params: { term_id: term.id, id: term_registration.id }

        expect(response).to have_http_status(:success)
      end
    end
  end
end
