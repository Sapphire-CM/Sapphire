require 'rails_helper'

RSpec.describe StudentGroupsController, :type => :controller do
  describe 'GET #index' do
    let(:term) { create(:term) }
    let(:tutorial_group) { create(:tutorial_group, term: term)}
    let(:student_groups_in_term) { create_list(:student_group, 4, tutorial_group: tutorial_group) }
    let(:student_groups_in_another_term) { create_list(:student_group, 4, tutorial_group: create(:tutorial_group)) }
    let(:account) { term_registration.account }

    let(:combined_student_groups) { student_groups_in_term + student_groups_in_another_term }

    context "as a lecturer" do
      let(:term_registration) { create(:term_registration, :lecturer, term: term)}

      it 'assigns @student_groups to the student groups in the current term' do
        expect(combined_student_groups.length).to eq(8)

        sign_in account

        get :index, term_id: term_registration.term.id

        expect(assigns[:student_groups]).to match_array(student_groups_in_term)
      end
    end
    context "as a student" do
      let(:term_registration) { create(:term_registration, :student, term: term)}

      it 'prohibits access' do
        sign_in account

        get :index, term_id: term_registration.term.id

        expect(response).not_to be_success
      end
    end
  end

  describe '#edit' do
  end

  describe '#update' do
  end

  describe '#search_students' do
  end
end
