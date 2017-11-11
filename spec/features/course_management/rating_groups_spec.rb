require 'rails_helper'

RSpec.feature 'Ratings and Rating Groups' do
  let(:account) { FactoryGirl.create(:account, :admin) }
  let(:course) { FactoryGirl.create(:course) }
  let(:term) { FactoryGirl.create(:term, course: course) }
  let!(:exercise) { FactoryGirl.create(:exercise, term: term) }

  before :each do
    sign_in account
  end

  scenario 'navigating to the ratings page' do
    visit root_path

    click_link term.title
    click_top_bar_link exercise.title
    click_sub_nav_link 'Ratings'

    expect(page).to have_current_path(exercise_rating_groups_path(exercise))
  end

  describe 'Rating Groups', js: true do
    before :each do
      visit exercise_rating_groups_path(exercise)
    end

    scenario 'creating a rating group' do
      click_link 'Add Rating Group'

      expect do
        within_modal do
          fill_in 'Title', with: 'My fancy Rating Group'
          fill_in 'Points', with: 9000

          click_button 'Save'
        end

        within '#rating_group_index_entries' do
          expect(page).to have_content('My fancy Rating Group')
        end
      end.to change(RatingGroup, :count).by(1)
    end

    context 'with existing rating group' do
      let!(:rating_group) { FactoryGirl.create(:rating_group, title: 'My Rating Group', exercise: exercise) }

      before :each do
        visit exercise_rating_groups_path(exercise)
      end

      scenario 'updating rating group'  do
        within "#rating_group_id_#{rating_group.id}" do
          first('.index_entry_edit').click
        end

        within_modal do
          fill_in 'Title', with: 'My fancy Rating Group'
          click_button 'Save'
        end

        within '#rating_group_index_entries' do
          expect(page).to have_content('My fancy Rating Group')
        end

        rating_group.reload
        expect(rating_group.title).to eq('My fancy Rating Group')
      end

      scenario 'updating point range of rating groups' do
        within "#rating_group_id_#{rating_group.id}" do
          first('.index_entry_edit').click
        end

        within_modal do
          fill_in 'Points', with: '5'

          hidden_inputs do
            fill_in 'Min points', with: '-5'
            fill_in 'Max points', with: '15'
          end

          click_button 'Save'
        end

        within '#rating_group_index_entries' do
          expect(page).to have_content('-5 ... 15')
        end

        rating_group.reload
        expect(rating_group.min_points).to eq(-5)
        expect(rating_group.max_points).to eq(15)
      end

      scenario 'removing a rating group' do
        expect do
          within "#rating_group_id_#{rating_group.id}" do
            first('.index_entry_remove').click
          end

          expect(page).not_to have_content('My Rating Group')
        end.to change(RatingGroup, :count).by -1

        expect(RatingGroup.find_by(id: rating_group.id)).not_to be_present
      end
    end

    scenario 'reordering of rating groups'
  end

  describe 'Ratings', js: true do
    let!(:rating_group) { FactoryGirl.create(:rating_group, exercise: exercise) }

    def within_rating_group(rg = nil, &block)
      within "#rating_group_id_#{(rg || rating_group).id}", &block
    end

    scenario 'creating a rating' do
      visit exercise_rating_groups_path(exercise)

      expect do
        within_rating_group do
          first('a[title="Add Rating"]').click
        end

        within_modal do
          fill_in 'Title', with: 'My fancy Rating'
          fill_in 'Points', with: '-4'
          click_button 'Save'
        end

        within_rating_group do
          expect(page).to have_content('My fancy Rating')
        end
      end.to change(Rating, :count).by 1
    end

    scenario 'updating rating'
    scenario 'removing a rating' do
      rating = FactoryGirl.create(:fixed_points_deduction_rating, rating_group: rating_group, title: 'My great Rating')

      visit exercise_rating_groups_path(exercise)

      expect do
        within_rating_group do
          within "#rating_id_#{rating.id}" do
            first('a.index_entry_remove').click
          end

          expect(page).not_to have_content('My great Rating')
        end
      end.to change(Rating, :count).by(-1)

      expect(Rating.find_by(id: rating.id)).not_to be_present
    end

    scenario 'reordering of ratings'
    scenario 'moving rating to another rating group'
  end
end
