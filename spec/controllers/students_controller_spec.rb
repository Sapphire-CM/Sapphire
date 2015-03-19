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
      get :index, term_id: term.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term_registrations)).to match_array(term.term_registrations.students)
      expect(assigns(:term_registrations)).to include(*students)
      expect(assigns(:term_registrations)).not_to include(*tutors)
      expect(assigns(:term_registrations)).not_to include(*lecturers)
      expect(assigns(:grading_scale)).to be_a(GradingScaleService)
    end

    context 'as a tutor' do
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let!(:tutor_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, tutorial_group: tutorial_group) }

      before :each do
        account = tutor_registration.account
        sign_in account
      end

      it 'returns a successful response' do
        get :index, term_id: term.id

        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET show' do
    let(:tutorial_group) { create(:tutorial_group, term: term) }
    let(:term_registration) {create(:term_registration, :student, term: term, tutorial_group: tutorial_group) }
    let(:student_group) { create(:student_group, tutorial_group: tutorial_group) }

    it 'assigns the requested exercise_registrations as @exercise_registrations' do
      term = FactoryGirl.create :term
      term_registration = FactoryGirl.create :term_registration, term: term
      FactoryGirl.create :exercise_registration, term_registration: term_registration

      get :show, term_id: term.id, id: term_registration.id

      expect(response).to have_http_status(:success)
      expect(assigns(:exercise_registrations)).to match_array(term_registration.exercise_registrations)
    end

    it 'assigns @tutorial_group' do
      get :show, term_id: term.id, id: term_registration.id

      expect(response).to have_http_status(:success)
      expect(assigns(:tutorial_group)).to eq(tutorial_group)
    end

    it 'assigns @student_group, if one is present' do
      term_registration.update(student_group: student_group)

      get :show, term_id: term.id, id: term_registration.id

      expect(response).to have_http_status(:success)
      expect(assigns(:student_group)).to eq(student_group)
    end

    context 'as a tutor' do
      let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
      let!(:tutor_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, tutorial_group: tutorial_group) }

      before :each do
        account = tutor_registration.account
        sign_in account
      end

      it 'returns a successful response' do
        get :show, term_id: term.id, id: term_registration.id

        expect(response).to have_http_status(:success)
      end
    end
  end
end
