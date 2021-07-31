require 'rails_helper'

RSpec.feature "Sending welcome notifications" do
  let(:section_selector) { "*[data-behaviour=welcome-notifications]"}
  let(:account) { term_registration.account }
  let(:term_registration) { FactoryBot.create(:term_registration, :lecturer) }
  let(:term) { term_registration.term }

  before :each do
    sign_in account
  end

  describe 'navigation' do
    scenario 'Navigating to the welcome students section of term#edit page through the term path' do
      visit term_path(term)

      click_side_nav_link("Administrate")

      expect(page).to have_current_path(edit_term_path(term))
      expect(page).to have_css(section_selector)
    end
  end

  describe 'behaviour' do
    context 'without pending welcome notifications' do
      let!(:term_registrations) { FactoryBot.create_list(:term_registration, 3, welcomed_at: 2.days.ago, term: term) }

      scenario 'it says "All welcome notifications have been sent"' do
        visit edit_term_path(term)

        within section_selector do
          expect(page).to have_content("All welcome notifications have been sent.")
        end
      end

      scenario 'it hides the send notifications button' do
        visit edit_term_path(term)

        within section_selector do
          expect(page).not_to have_link("Send")
        end
      end
    end

    context 'with pending welcome notifications' do
      let!(:term_registrations) { FactoryBot.create_list(:term_registration, 3, welcomed_at: nil, term: term) }

      scenario 'it says "There are [count] welcome notifications waiting to be sent."' do
        visit edit_term_path(term)

        within section_selector do
          expect(page).to have_content("There are #{term_registrations.length} welcome notifications waiting to be sent.")
        end
      end

      scenario 'it shows the send notifications button' do
        visit edit_term_path(term)

        within section_selector do
          expect(page).to have_link("Send #{term_registrations.length} welcome notifications")
        end
      end

      scenario 'it sends pending welcome notifications' do
        visit edit_term_path(term)

        perform_enqueued_jobs do
          expect do
            within section_selector do

              click_link("Send #{term_registrations.length} welcome notifications")
            end

            expect(page).to have_content("queued for sending")
          end.to change(ActionMailer::Base.deliveries, :length).by(3)
        end
      end
    end
  end

end