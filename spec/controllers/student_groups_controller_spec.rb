require 'rails_helper'

RSpec.describe StudentGroupsController, :type => :controller do
  render_views
  include_context 'active_lecturer_session_context'

  let!(:term) { @current_account.term_registrations.lecturer.first.term }
  let!(:tutorial_group) { create(:tutorial_group, term: term)}
  let(:student_group) {create(:student_group, tutorial_group: tutorial_group)}

  let(:student_term_registrations) { create_list(:term_registration, 4, term: term, tutorial_group: tutorial_group) }

  let(:valid_attributes) do
    {
      title: "G4-05",
      term_registration_ids: student_term_registrations.map(&:id)
    }
  end

  let(:invalid_attributes) do
    {
      title: "",
      term_registration_ids: []
    }
  end

  let(:path_options) { {term_id: term.id, tutorial_group_id: tutorial_group.id} }
  let(:path_options_with_student_group) { path_options.merge({id: student_group.id})}


  describe 'GET #index' do
    let!(:student_groups) { create_list(:student_group, 4, tutorial_group: tutorial_group) }
    let!(:student_groups_in_another_tutorial_group) { create_list(:student_group, 4, tutorial_group: create(:tutorial_group, term: term)) }

    it 'assigns @student_groups to the student groups in the current term' do
      get :index, path_options

      expect(assigns[:student_groups]).to match_array(student_groups)
    end
  end

  describe '#show' do
    let!(:student_term_registrations) { create_list(:term_registration, 4, :student, student_group: student_group, term: term, tutorial_group: tutorial_group) }
    let!(:exercises) { create_list(:exercise, 2, term: term) }
    let!(:submissions) { exercises.map {|exercise| create(:submission, exercise: exercise, student_group: student_group)} }

    it 'assigns @student_group' do
      get :show, path_options_with_student_group

      expect(response).to have_http_status(:success)
      expect(assigns(:student_group)).to eq(student_group)
    end

    it 'assigns @submissions' do
      get :show, path_options_with_student_group

      expect(response).to have_http_status(:success)
      expect(assigns(:submissions)).to match_array(submissions)
    end

    it 'assigns @student_term_registrations' do
      get :show, path_options_with_student_group

      expect(response).to have_http_status(:success)
      expect(assigns(:student_term_registrations)).to match_array(student_term_registrations)
    end

  end

  describe '#new' do
    it 'assigns @student_group to a new one' do
      get :new, path_options

      expect(response).to have_http_status(:success)
      expect(assigns(:student_group)).to be_a_new(StudentGroup)
      expect(assigns(:student_group).tutorial_group).to eq(tutorial_group)
    end
  end

  describe '#create' do
    describe 'with valid attributes' do
      it 'creates a new student group' do
        expect do
          post :create, path_options.merge(student_group: valid_attributes)
        end.to change(StudentGroup, :count).by 1

        expect(assigns(:student_group).title).to eq("G4-05")
        expect(assigns(:student_group).term_registrations).to match_array(student_term_registrations)
      end
    end

    describe 'with invalid attributes' do
      it 'does not create a student group' do
        expect do
          post :create, path_options.merge(student_group: invalid_attributes)
        end.not_to change(StudentGroup, :count)

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:student_group)).to be_a_new(StudentGroup)
        expect(assigns(:student_group).errors).to be_present
      end

    end
  end

  describe '#edit' do
    it 'assigns @student_group to the specified one' do
      get :edit, path_options_with_student_group

      expect(response).to have_http_status(:success)
      expect(assigns(:student_group)).to eq(student_group)
    end
  end

  describe '#update' do
    describe 'with valid attributes' do
      it 'updates the given student group' do
        put :update, path_options_with_student_group.merge(student_group: valid_attributes)

        student_group.reload
        expect(student_group.title).to eq("G4-05")
        expect(student_group.term_registrations).to match_array(student_term_registrations)
      end
    end

    describe 'with invalid attributes' do
      it 'does not update the given student group' do
        put :update, path_options_with_student_group.merge(student_group: invalid_attributes)

        expect(assigns(:student_group).errors).to be_present
        expect(response).to render_template(:edit)
      end
    end
  end

  describe '#destroy' do
    it 'removes the given student group' do
      student_group.reload

      expect do
        delete :destroy, path_options_with_student_group
      end.to change(StudentGroup, :count).by -1

      expect(response).to redirect_to(term_tutorial_group_student_groups_path(term, tutorial_group))
    end
  end

  describe '#search_students' do
    let!(:student_registrations_in_term) { create_list(:term_registration, 4, :student, term: term, tutorial_group: create(:tutorial_group, term: term))}
    let(:another_term) { create(:term, course: term.course) }
    let!(:student_registrations_in_another_term) { create_list(:term_registration, 4, :student, term: another_term, tutorial_group: create(:tutorial_group, term: another_term))}

    it 'assigns @term_registrations with students of given term' do
      student_registrations_in_term.first(2).flat_map(&:account).each {|a| a.update!(forename: "Ron") }

      xhr :get, :search_students, path_options.merge(q: "Ron")

      expect(response).to have_http_status(:success)
      expect(assigns(:term_registrations)).to match_array(student_registrations_in_term.first(2))
    end

    it 'returns a response with status bad request, when no q parameter is present' do
      xhr :get, :search_students, path_options

      expect(response).to have_http_status(:bad_request)
      expect(response.body).to be_blank
    end

    it 'issues search when q parameter is present' do
      expect(TermRegistration).to receive(:search).with("Ron Burgundy").and_return(TermRegistration.where(id: student_registrations_in_term.first.id))

      xhr :get, :search_students, path_options.merge(q: "Ron Burgundy")

      expect(response).to have_http_status(:success)
      expect(assigns(:term_registrations)).to eq(student_registrations_in_term.first(1))
    end
  end
end
