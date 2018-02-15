require 'rails_helper'
require 'features/account_management/behaviours/account_side_navigation_behaviour'

RSpec.feature 'Account Details' do
  let(:admin_account) { FactoryGirl.create(:account, :admin) }
  let!(:student_account) { FactoryGirl.create(:account, :student, forename: 'Sam', surname: 'Secret') }
  let(:term) { student_term_registration.term }
  let(:student_term_registration) { student_account.term_registrations.student.first }

  shared_examples "Account Detail" do
    scenario 'Viewing an account' do
      visit account_path(student_account)

      within '#site_title' do
        expect(page).to have_content('Sam Secret')
      end

      expect(page).to have_content(term.title)
    end

    scenario 'Presents links to participated terms' do
      visit account_path(student_account)

      within "table.terms" do
        expect(page).to have_link(term.title, href: term_path(term))
      end
    end
  end

  context 'as an admin' do
    before(:each) do
      sign_in admin_account
    end

    describe 'behaviours' do
      let(:base_path) { account_path(student_account) }
      let(:account) { student_account }

      it_behaves_like "Account Side Navigation"
      it_behaves_like "Account Detail"
    end

    scenario 'Navigating to account#show' do
      visit accounts_path

      within "table.accounts" do
        click_link "View", href: account_path(student_account)
      end

      expect(page).to have_current_path(account_path(student_account))
    end

    scenario 'Provides link to details in participated term' do
      visit account_path(student_account)

      expect(page).to have_link("Show", href: term_student_path(term, student_term_registration))
    end

    scenario 'Presents the points column' do
      visit account_path(student_account)

      within "table.terms" do
        expect(page).to have_content "Points"
      end
    end

    scenario 'Provides impersonation link' do
      visit account_path(student_account)

      expect(page).to have_link("Impersonate", href: impersonation_path(account_id: student_account.id))
    end

    scenario 'Hides impersonation if visiting own account' do
      visit account_path(admin_account)

      expect(page).not_to have_link("Impersonate")
    end
  end

  context 'as student' do
    before :each do
      sign_in student_account
    end

    describe 'behaviours' do
      let(:base_path) { account_path(student_account) }
      let(:account) { student_account }

      it_behaves_like "Account Side Navigation"
      it_behaves_like "Account Detail"
    end

    scenario 'Does not show points column' do
      visit account_path(student_account)

      within 'table.terms' do
        expect(page).not_to have_content("Points")
      end
    end

    scenario 'Does not link to student details of terms' do
      visit account_path(student_account)

      within 'table.terms' do
        expect(page).not_to have_link(href: term_student_path(term, student_term_registration))
      end
    end

    scenario 'Does not provide impersonation link' do
      visit account_path(student_account)

      expect(page).not_to have_link("Impersonate")
    end
  end

end