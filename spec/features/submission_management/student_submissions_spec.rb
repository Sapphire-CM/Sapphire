require 'rails_helper'

RSpec.describe 'Managing submissions as a student' do
  let(:course) { FactoryGirl.create(:course) }
  let(:term) { FactoryGirl.create(:term, course: course, title: 'Fancy Term') }
  let(:term_registration) { FactoryGirl.create(:term_registration, :student, term: term) }
  let!(:account) { term_registration.account }
  let!(:exercise) { FactoryGirl.create(:exercise, title: 'Fancy Exercise', term: term)}

  before :each do
    sign_in account
  end

  describe 'navigating to the submission page' do
    before :each do
      visit root_path
    end

    scenario 'through the term page' do
      click_top_bar_link 'Fancy Term'
      click_side_nav_link 'Exercises'

      within 'table' do
        click_link 'Fancy Exercise'
      end

      expect(page.current_path).to eq(exercise_student_submission_path(exercise))
    end

    scenario 'though the navigation bar' do
      click_top_bar_link 'Fancy Term'
      click_top_bar_link 'Fancy Exercise'

      expect(page.current_path).to eq(exercise_student_submission_path(exercise))
    end
  end

  describe 'submitting' do
    before :each do
      visit exercise_student_submission_path(exercise)
    end

    scenario 'a single file', js: true do
      attach_file 'Fancy Exercise file', 'spec/support/data/simple_submission.txt'

      click_button 'Upload Submission'

      within 'table#submission_assets_list' do
        expect(page).to have_content('simple_submission.txt')
        expect(page).to have_content(account.forename)
        expect(page).to have_content(account.surname)
      end
    end

    scenario 'multiple single files', js: true do
      click_link 'Add File'
      click_link 'Add File'

      expect(page).to have_css('#submission_asset_fields .row', count: 3)

      within '#submission_asset_fields .row:nth-child(1)' do
        attach_file 'Fancy Exercise file', 'spec/support/data/simple_submission.txt'
      end

      within '#submission_asset_fields .row:nth-child(2)' do
        attach_file 'Fancy Exercise file', 'spec/support/data/simple_submission_2.txt'
      end

      within '#submission_asset_fields .row:nth-child(3)' do
        attach_file 'Fancy Exercise file', 'spec/support/data/submission_asset_iso_latin.txt'
      end

      click_button 'Upload Submission'

      expect(page).to have_content('simple_submission.txt')
      expect(page).to have_content('simple_submission_2.txt')
      expect(page).to have_content('submission_asset_iso_latin.txt')
    end

    scenario 'a .zip file', js: true do
      attach_file 'Fancy Exercise file', 'spec/support/data/submission.zip'

      click_button 'Upload Submission'

      expect(page.current_path).to eq(catalog_exercise_student_submission_path(exercise))

      click_link 'Check all'
      click_button 'Extract'

      within 'table#submission_assets_list' do
        expect(page).to have_content('simple_submission.txt')
        expect(page).to have_content('some_xa__x_xu__x_xo__x_x__x_nasty_file.txt')
      end
    end

    context 'small exercise uploads' do
      let(:exercise) { FactoryGirl.create(:exercise, title: 'Fancy Exercise', term: term, enable_max_upload_size: true, maximum_upload_size: 50) }

      before :each do
        visit exercise_student_submission_path(exercise)
      end

      scenario 'a file, which is too large', js: true do
        attach_file 'Fancy Exercise file', 'spec/support/data/simple_submission.txt'

        click_button 'Upload Submission'

        expect(page).to have_content('too large')
      end
    end
  end

  context 'existing submission' do

    before :each do
      visit exercise_student_submission_path(exercise)

      attach_file 'Fancy Exercise file', 'spec/support/data/simple_submission.txt'
      click_button 'Upload Submission'

      visit exercise_student_submission_path(exercise)
    end

    scenario 'replacing a file' do
      attach_file 'Fancy Exercise file', 'spec/support/data/simple_submission_2.txt'
      click_button 'Update Submission'

      expect(page).to have_no_content('simple_submission.txt')
      expect(page).to have_content('simple_submission_2.txt')

    end

    scenario 'removing a file', js: true do
      visit exercise_student_submission_path(exercise)

      within '#submission_asset_fields' do
        first('a.remove_fields').click
      end

      click_button 'Update Submission'

      expect(page).to have_no_content('simple_submission.txt')
    end
  end
end
