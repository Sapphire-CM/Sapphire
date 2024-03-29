require "rails_helper"

RSpec.feature 'Student Groups Deletion' do
  let(:account) { FactoryBot.create(:account) }
  let(:term) { FactoryBot.create(:term) }
  let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, term: term, account: account) }

  let(:tutorial_group) { FactoryBot.create(:tutorial_group, term: term) }
  let!(:student_group) {FactoryBot.create(:student_group, tutorial_group: tutorial_group) }
  let!(:other_student_group) {FactoryBot.create(:student_group, tutorial_group: tutorial_group) }

  before :each do
    sign_in account
  end

  scenario 'Deleting a student group' do
    visit edit_term_student_group_path(term, student_group)

    click_link "Delete Student Group"

    expect(page).to have_current_path(term_student_groups_path(term))

    within 'table.student-groups' do
      expect(page).not_to have_content(student_group.title)
      expect(page).to have_content(other_student_group.title)
    end
  end
end