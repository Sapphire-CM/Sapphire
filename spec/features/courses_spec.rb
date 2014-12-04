require 'rails_helper'

describe "Courses" do
  context "student" do
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

    it "should display a link to the current course" do
      visit root_path

      page.should have_content(course.title)
      page.should have_link(term.title)
    end

    it "should not display links to terms to unassociated terms" do
      other_term = create(:term)
      page.should_not have_link other_term.title
    end

    it "should not display unassociated courses" do
      other_course = create(:course)
      page.should_not have_content(other_course.title)
    end

    it "should not have add or edit links" do
      visit root_path

      page.should_not have_link("Add Course")
      page.should_not have_selector("a[title='Add Term']")
      page.should_not have_selector("a.index_entry_edit")
      page.should_not have_selector("a.index_entry_remove")
    end

    it "should not render empty tds" do
      visit root_path

      page.all("td").each do |table_cell|
        table_cell.text.should_not be_blank
      end
    end
  end
end
