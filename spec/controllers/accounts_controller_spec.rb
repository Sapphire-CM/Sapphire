require 'rails_helper'

RSpec.describe AccountsController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      account: {
        email: 'account@example.com',
        forename: 'John the Fifth',
        surname: 'Doe',
        matriculation_number: '1234567',
      }
    }
  end

  let(:invalid_attributes) do
    {
      account: {
        email: 'invalid_account.com',
        forename: 'John',
        surname: 'Doe',
        matriculation_number: 'invalid',
      }
    }
  end

  let(:account) { FactoryGirl.create :account }

  describe 'GET index' do
    it 'assigns all accounts as @accounts' do
      FactoryGirl.create_list :account, 4

      get :index

      expect(response).to have_http_status(:success)
      expect(assigns(:accounts)).to eq(Kaminari.paginate_array(Account.all).page(1))
    end
  end

  describe 'GET show' do
    it 'assigns the requested account as @account' do
      get :show, id: account.id

      expect(response).to have_http_status(:success)
      expect(assigns(:account)).to eq(account)
      expect(assigns(:term_registrations)).to eq(account.term_registrations)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested account as @account' do
      xhr :get, :edit, id: account.id

      expect(response).to have_http_status(:success)
      expect(assigns(:account)).to eq(account)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested account' do
        valid_attributes[:id] = account.id

        put :update, valid_attributes

        account.reload
        expect(response).to redirect_to(root_path)
        expect(account.forename).to eq valid_attributes[:account][:forename]
        expect(account.surname).to eq valid_attributes[:account][:surname]
        expect(account.matriculation_number).to eq valid_attributes[:account][:matriculation_number]
      end

      it 'updates the password' do
        valid_attributes[:id] = account.id
        valid_attributes[:account][:current_password] = account.password
        valid_attributes[:account][:password] = 'asdfghjkl'
        valid_attributes[:account][:password_confirmation] = valid_attributes[:account][:password]

        expect do
          put :update, valid_attributes
          account.reload
        end.to change(account, :encrypted_password)

        expect(response).to redirect_to(root_path)
      end
    end

    describe 'with invalid params' do
      it 'assigns the requested account as @account' do
        invalid_attributes[:id] = account.id

        put :update, invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
        expect(assigns(:account)).to eq(account)
      end

      context 'update the password' do
        it 'fails if the current password is wrong' do
          invalid_attributes[:id] = account.id
          invalid_attributes[:account][:current_password] = 'foobar'
          invalid_attributes[:account][:password] = 'asdfghjkl'
          invalid_attributes[:account][:password_confirmation] = invalid_attributes[:account][:password]

          expect do
            put :update, invalid_attributes
            account.reload
          end.not_to change(account, :encrypted_password)

          expect(response).to render_template(:edit)
          expect(assigns(:account)).to eq(account)
        end

        it 'fails if they mismatch' do
          invalid_attributes[:id] = account.id
          invalid_attributes[:account][:current_password] = 'secret'
          invalid_attributes[:account][:password] = 'asdfghjkl'
          invalid_attributes[:account][:password_confirmation] = 'foobar'

          expect do
            put :update, invalid_attributes
            account.reload
          end.not_to change(account, :encrypted_password)

          expect(response).to render_template(:edit)
          expect(assigns(:account)).to eq(account)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested account' do
      account.reload # trigger creation

      expect do
        delete :destroy, id: account.id
      end.to change(Account, :count).by(-1)

      expect(response).to redirect_to(accounts_path)
    end
  end
end
