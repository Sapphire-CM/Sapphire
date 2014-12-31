require 'rails_helper'

RSpec.describe 'Password Change' do
  context 'as student' do
    let(:current_account) { FactoryGirl.create :account }

    before :each do
      current_account.update! password: 'secret123', password_confirmation: 'secret123'
      sign_in current_account
      visit edit_account_path(current_account)
    end

    context 'with correct current password' do
      context 'with matching passwords' do
        it 'changes my password' do
          fill_in 'Current password', with: 'secret123'
          fill_in 'Password', with: 'foobar'
          fill_in 'Password confirmation', with: 'foobar'

          expect {
            click_button 'Save'
            current_account.reload
          }.to change(current_account, :encrypted_password)

        end
      end

      context 'with non-matching passwords' do
        it 'does not change my password' do
          fill_in 'Current password', with: 'secret123'
          fill_in 'Password', with: 'foobar'
          fill_in 'Password confirmation', with: 'bar'

          expect {
            click_button 'Save'
            current_account.reload
          }.not_to change(current_account, :encrypted_password)

          expect(page).to have_selector('.account_password_confirmation.error')
        end
      end
    end

    context 'with wrong current password' do
      it 'does not change my password' do
        fill_in 'Current password', with: 'qwertasdfzxcv'
        fill_in 'Password', with: 'foobar'
        fill_in 'Password confirmation', with: 'foobar'

        expect {
          click_button 'Save'
          current_account.reload
        }.not_to change(current_account, :encrypted_password)

        expect(page).to have_selector('.account_current_password.error')
      end
    end
  end
end
