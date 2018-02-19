require 'rails_helper'

RSpec.describe StaffController do
  render_views
  include_context 'active_admin_session_context'

  let(:term) { FactoryGirl.create :term }
  let(:term_registration) { FactoryGirl.create :term_registration, term: term }
  let(:account) { FactoryGirl.create :account }
  let(:tutorial_group) { FactoryGirl.create :tutorial_group, term: term }

  describe 'GET index' do
    it 'assigns all term_registrations as @term_registrations' do
      students = FactoryGirl.create_list :term_registration, 4, :student, term: term
      tutors = FactoryGirl.create_list :term_registration, 4, :tutor, term: term
      lecturers = FactoryGirl.create_list :term_registration, 4, :lecturer, term: term

      get :index, term_id: term.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term_registrations)).to match_array(term.term_registrations.staff)
      expect(assigns(:term_registrations)).not_to include(*students)
      expect(assigns(:term_registrations)).to include(*tutors)
      expect(assigns(:term_registrations)).to include(*lecturers)
    end
  end

  describe 'GET new' do
    it 'assigns a new term_registration as @term_registration' do
      get :new, term_id: term.id

      expect(response).to have_http_status(:success)
      expect(assigns(:term_registration)).to be_a_new(TermRegistration)
      expect(assigns(:term_registration).term).to eq(term)
      expect(assigns(:term_registration).role).to eq(Roles::TUTOR)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new TermRegistration for a LECTURER' do
        valid_attributes = {
          term_id: term.id,
          term_registration: {
            account_id: account.id,
            role: Roles::LECTURER,
          }
        }

        expect do
          post :create, valid_attributes
        end.to change(TermRegistration, :count).by(1)

        expect(response).to redirect_to(term_staff_index_path(term))
        expect(assigns(:term_registration).term).to eq(term)
        expect(assigns(:term_registration).account).to eq(account)
        expect(assigns(:term_registration).role).to eq(Roles::LECTURER)
        expect(assigns(:term_registration).tutorial_group).to be_nil
      end

      it 'creates a new TermRegistration for a TUTOR' do
        valid_attributes = {
          term_id: term.id,
          term_registration: {
            account_id: account.id,
            role: Roles::TUTOR,
            tutorial_group_id: tutorial_group.id
          }
        }

        expect do
          post :create, valid_attributes
        end.to change(TermRegistration, :count).by(1)

        expect(response).to redirect_to(term_staff_index_path(term))
        expect(assigns(:term_registration).term).to eq(term)
        expect(assigns(:term_registration).account).to eq(account)
        expect(assigns(:term_registration).role).to eq(Roles::TUTOR)
        expect(assigns(:term_registration).tutorial_group).to eq(tutorial_group)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved term_registration as @term_registration' do
        invalid_attributes = {
          term_id: term.id,
          term_registration: {
            account_id: '0',
          }
        }

        expect do
          post :create, invalid_attributes
        end.to change(TermRegistration, :count).by(0)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:term_registration)).to be_a_new(TermRegistration)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested term_registration' do
      term_registration.reload # trigger creation

      expect do
        xhr :delete, :destroy, term_id: term.id, id: term_registration.id
      end.to change(TermRegistration, :count).by(-1)

      expect(response).to redirect_to(term_staff_index_path(term))
    end
  end
end
