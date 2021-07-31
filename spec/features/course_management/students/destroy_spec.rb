require 'rails_helper'

RSpec.describe 'Removing students from a term' do
  let(:term) { FactoryBot.create(:term) }
  let(:account) { FactoryBot.create(:account, :admin) }

  before :each do
    sign_in account
  end

  let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
  let!(:student_term_registration) { FactoryBot.create(:term_registration, :student, :with_student_group, term: term, tutorial_group: tutorial_group) }

  scenario 'using the students edit page' do
    visit edit_term_student_path(term, student_term_registration)

    expect do
      within ".panel.alert" do
        click_link "Delete Student"
      end
    end.to change(TermRegistration, :count).by(-1)

    expect(page).to have_content("successfully")
    expect(page).to have_current_path(term_students_path(term))
  end
end