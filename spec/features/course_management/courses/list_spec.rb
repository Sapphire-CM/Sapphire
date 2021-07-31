require "rails_helper"

RSpec.describe 'Courses List' do
  let(:account) { FactoryBot.create(:account, :admin) }

  before :each do
    sign_in account
  end

  context 'without courses' do
    scenario "Visiting courses list shows empty list notice" do
      visit root_path

      expect(page).to have_content("No courses present")
    end

    scenario 'Presenting new course link' do
      expect(page).to have_link("Add Course")
    end
  end

  context 'with courses without terms' do
    let!(:courses) { FactoryBot.create_list(:course, 3) }

    scenario 'Viewing course titles' do
      visit root_path

      courses.each do |course|
        within "#course_id_#{course.id}" do
          expect(page).to have_content(course.title)
        end
      end
    end

    scenario 'Presenting edit links' do
      visit root_path

      courses.each do |course|
        within "#course_id_#{course.id}" do
          expect(page).to have_link(href: edit_course_path(course))
        end
      end
    end

    scenario 'Presenting deletion links' do
      visit root_path

      courses.each do |course|
        within "#course_id_#{course.id}" do
          expect(page).to have_css("a[href='#{course_path(course)}'][data-method=delete]")
        end
      end
    end

    scenario 'Presenting new term link' do
      visit root_path

      courses.each do |course|
        within "#course_id_#{course.id}" do
          expect(page).to have_link(href: new_term_path(course_id: course.id))
        end
      end
    end

    scenario 'Presenting empty notice' do
      visit root_path

      courses.each do |course|
        within "#course_id_#{course.id}" do
          expect(page).to have_content("No terms present.")
        end
      end
    end
  end

  context 'with two courses having three terms' do
    let!(:courses) { FactoryBot.create_list(:course, 3, :with_terms) }
    let(:terms) { courses.flat_map(&:terms) }

    scenario 'Term table is sortable' do
      visit root_path

      courses.each do |course|
        within "#course_id_#{course.id}" do
          expect(page).to have_css("table.sortable")
        end
      end
    end

    scenario 'Linking to terms' do
      visit root_path

      courses.each do |course|
        within "#course_id_#{course.id}" do
          course.terms.each do |term|
            expect(page).to have_link(term.title)
          end
        end
      end
    end

    scenario 'Presenting students column' do
      visit root_path

      courses.each do |course|
        within "#course_id_#{course.id} table.sortable thead" do
          expect(page).to have_content("Students")
        end
      end
    end

    context 'as student' do
      let(:course) { term.course }
      let(:term) { terms.first }
      let(:other_term) { terms.last }
      let!(:term_registration) { FactoryBot.create(:term_registration, :student, term: term, account: account) }

      before :each do
        account.update(admin: false)
      end

      scenario 'Viewing term' do
        visit root_path

        expect(page).to have_content(term.title)
        expect(page).to have_content(term.course.title)
        expect(page).to have_link(term.title)
      end

      scenario 'Not seeing other terms' do
        visit root_path

        terms.each do |a_term|
          next if a_term == term

          expect(page).not_to have_content(a_term.title)
          expect(page).not_to have_link(a_term.title)

          unless a_term.course == term.course
            expect(page).not_to have_content(a_term.course.title)
          end
        end
      end

      scenario 'Hiding students column' do
        visit root_path

        within "table.sortable thead" do
          expect(page).not_to have_content("Students")
        end
      end

      scenario 'Hiding new course link' do
        visit root_path

        expect(page).not_to have_link("Add Course")
      end

      scenario 'Hiding course edit link' do
        visit root_path

        within "#course_id_#{course.id}" do
          expect(page).not_to have_link(href: edit_course_path(course))
        end
      end

      scenario 'Hiding removal link' do
        visit root_path

        within "#course_id_#{course.id}" do
          expect(page).not_to have_css("a[href='#{course_path(course)}'][data-method=delete]")
        end
      end
    end
  end
end