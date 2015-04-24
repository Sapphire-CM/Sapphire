require 'rails_helper'

RSpec.describe 'Courses Feature' do
  context 'student' do
    let(:course) { FactoryGirl.create(:course) }
    let(:term) { FactoryGirl.create(:term, course: course) }
    let(:tutorial_group) { FactoryGirl.create(:tutorial_group, term: term) }
    let(:student) do
      student = FactoryGirl.create(:account)
      FactoryGirl.create(:term_registration, :student, account: student, term: term, tutorial_group: tutorial_group)
      student
    end

    before(:each) do
      sign_in(student)
    end

    it 'displays a link to the current course' do
      visit root_path

      expect(page).to have_content(course.title)
      expect(page).to have_link(term.title)
    end

    it 'does not display links to terms to unassociated terms' do
      other_term = create(:term)
      expect(page).not_to have_link other_term.title
    end

    it 'does not display unassociated courses' do
      other_course = create(:course)
      expect(page).not_to have_content(other_course.title)
    end

    it 'does not have add or edit links' do
      visit root_path

      expect(page).not_to have_link('Add Course')
      expect(page).not_to have_selector("a[title='Add Term']")
      expect(page).not_to have_selector('a.index_entry_edit')
      expect(page).not_to have_selector('a.index_entry_remove')
    end

    it 'does not render empty tds' do
      visit root_path

      page.all('td').each do |table_cell|
        expect(table_cell.text).not_to be_blank
      end
    end
  end
end
