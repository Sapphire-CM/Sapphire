require 'rails_helper'

RSpec.describe 'Commenting' do
  let(:term) { FactoryGirl.create(:term) }
  let(:account) { FactoryGirl.create(:account, :admin) }
  let!(:term_registration) { FactoryGirl.create(:term_registration, :tutor, term: term, account: account) }
  let!(:exercise) { FactoryGirl.create(:exercise, term: term)}
  let(:submission) { FactoryGirl.create(:submission, exercise: exercise) }
  let(:submission_evaluation) { submission.submission_evaluation }

  before :each do
    sign_in(account)
  end


  describe 'navigating' do
    scenario 'to feedback comment modal', js: true do
      visit (submission_evaluation_path(submission_evaluation))

      within '.evaluation-top-bar' do
        click_on text: 'Add Feedback'
      end

      expect(page).to have_css('#reveal_modal', class: 'open')
    end
  end

  describe 'posting a comment' do
    scenario 'with valid content', js: true do
      visit (submission_evaluation_path(submission_evaluation))

      within '.evaluation-top-bar' do
        click_on text: 'Add Feedback'
      end

      expect do
        within_modal do
          fill_in 'Feedback', 'some comment'

          click_button 'Save'
        end

        within '.comments_list' do
          expect(page).to have_content("Feedback from #{account.fullname}")
          expect(page).to have_content('some comment')
        end
      end

      expect(page).to have_css('#reveal_modal', class: 'open')
    end

    scenario 'without valid content', js: true do
      visit (submission_evaluation_path(submission_evaluation))

      within '.evaluation-top-bar' do
        click_on text: 'Add Feedback'
      end

      within_modal do
        fill_in 'Feedback', with: ""

        click_button 'Save'

        expect(page).to have_content("can't be blank")
      end

      expect(page).to have_css('#reveal_modal', class: 'open')
      expect(page).to have_content("can't be blank")
    end
  end

  describe 'editing a comment' do
    let!(:comment) { FactoryGirl.create :feedback_comment, commentable: submission_evaluation }
    scenario 'to another valid comment', js: true do
      visit (submission_evaluation_path(submission_evaluation))

      within '.evaluation-top-bar' do
        click_on text: 'Feedback (1)'
      end

      wait_for_ajax do
        within_modal do
          within '.comments_list' do
            click_link id: 'feedback_comment_edit_submission_evaluation_1'

            fill_in 'Feedback', with: 'this is an edited comment'

            click_button 'Save'
          end
        end
      end

      expect(page).to have_content('this is an edited comment')
    end

    scenario 'to invalid comment', js: true do
      visit (submission_evaluation_path(submission_evaluation))

      within '.evaluation-top-bar' do
        click_on text: 'Feedback (1)'
      end

      wait_for_ajax do
        within_modal do
          within '.comments_list' do
            click_link id: 'feedback_comment_edit_submission_evaluation_1'

            fill_in 'Feedback', with: ''

            click_button 'Save'
          end
        end
      end


      expect(page).to have_content("Feedback can't be blank")
    end
  end

  describe 'managing' do
    let!(:comment) { FactoryGirl.create :feedback_comment, commentable: submission_evaluation }
    scenario 'deleting a comment', js: true do
      visit (submission_evaluation_path(submission_evaluation))

      within '.evaluation-top-bar' do
        click_on text: 'Feedback (1)'
      end

      wait_for_ajax do
        within_modal do
          within '.comments_list' do
            click_link id: 'feedback_comment_delete_submission_evaluation_1'
          end
        end

        expect(page).to have_content('No Feedback Yet!')
      end
    end
  end
end
