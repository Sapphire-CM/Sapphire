require 'rails_helper'

RSpec.describe "Tutorial Groups List" do
  let(:term) { FactoryBot.create(:term) }
  let(:account) { FactoryBot.create(:account, :admin) }

  let(:described_path) { term_tutorial_groups_path(term) }

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'from term dashboard side nav' do
      visit term_path(term)

      click_side_nav_link("Tutorial Groups")

      expect(page).to have_current_path(described_path)
    end

    scenario 'from term top bar' do
      visit term_path(term)

      click_top_bar_link("Tutorial Groups")

      expect(page).to have_current_path(described_path)
    end
  end

  describe 'highlight' do
    scenario 'in side nav' do
      visit described_path

      expect(page).to highlight_side_nav_link("Tutorial Groups")
    end
  end

  describe 'tutorial groups list' do
    scenario 'shows new tutorial group link' do
      visit described_path

      within_main do
        expect(page).to have_link("New Tutorial Group", href: new_term_tutorial_group_path(term))
      end
    end

    context 'without tutorial group' do
      scenario 'shows no tutorial group present' do
        visit described_path

        within_main do
          expect(page).to have_content("No tutorial groups present.")
        end
      end
    end

    context 'with tutorial group' do
      let!(:tutorial_group) { FactoryBot.create(:tutorial_group, :with_tutor, term: term) }

      let(:tutor_account) { tutorial_group.tutor_accounts.last }

      scenario 'links to tutorial group and shows tutors' do
        visit described_path

        within_main do
          expect(page).to have_link(tutorial_group.title)
          expect(page).to have_content(tutor_account.fullname)
        end
      end

      context 'as tutor' do
        let(:account) { tutor_account }

        scenario 'hides add new tutorial group link' do
          visit described_path

          within_main do
            expect(page).not_to have_link("New Tutorial Group")
          end
        end
      end
    end

  end
end