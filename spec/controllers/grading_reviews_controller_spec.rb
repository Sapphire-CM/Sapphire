require 'rails_helper'

RSpec.describe GradingReviewsController do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryBot.create :term }

  describe 'GET #index' do
    let!(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
    let!(:student_group) { FactoryBot.create(:student_group, tutorial_group: tutorial_group) }
    let!(:student_term_registration) { FactoryBot.create(:term_registration, :student, term: term, student_group: student_group) }
    let!(:other_student_term_registration) { FactoryBot.create(:term_registration, :student) }
    let!(:tutor_term_registration) { FactoryBot.create(:term_registration, :tutor, term: term) }
    let!(:lecturer_term_registration) { FactoryBot.create(:term_registration, :lecturer, term: term) }

    it 'renders :index' do
      get :index, params: { term_id: term.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end

    context 'without a search query' do
      it 'does not assign @term_registrations' do
        get :index, params: { term_id: term.id }

        expect(assigns(:term_registrations)).to be_blank
      end
    end

    context 'with search query' do
      let(:student_account) { student_term_registration.account }
      let(:other_student_account) { other_student_term_registration.account }
      let(:tutor_account) { tutor_term_registration.account}
      let(:lecturer_account) { tutor_term_registration.account}

      it 'assigns student term registrations to @term_registrations' do
        get :index, params: { term_id: term.id, q: student_account.fullname }

        expect(response).to have_http_status(:success)
        expect(assigns(:term_registrations)).to match_array([student_term_registration])
      end

      it 'does not assign students of other terms to @term_registrations' do
        get :index, params: { term_id: term.id, q: other_student_account.fullname }

        expect(response).to have_http_status(:success)
        expect(assigns(:term_registrations)).to match_array([])
      end

      it 'does not assign tutors to @term_registrations' do
        get :index, params: { term_id: term.id, q: tutor_account.fullname }

        expect(response).to have_http_status(:success)
        expect(assigns(:term_registrations)).to match_array([])
      end

      it 'does not assign lecturers to @term_registrations' do
        get :index, params: { term_id: term.id, q: lecturer_account.fullname }

        expect(response).to have_http_status(:success)
        expect(assigns(:term_registrations)).to match_array([])
      end
    end
  end

  describe 'GET #show' do
    let(:term_registration) { FactoryBot.create(:term_registration, :student, term: term) }

    it 'renders show template' do
      get :show, params: { term_id: term.id, id: term_registration.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
    end

    it 'assigns @term_review' do
      get :show, params: { term_id: term.id, id: term_registration.id }

      expect(response).to have_http_status(:success)
      expect(assigns[:term_review]).to be_a(GradingReview::TermReview)
      expect(assigns[:term_review].term_registration).to eq(term_registration)
    end
  end
end
