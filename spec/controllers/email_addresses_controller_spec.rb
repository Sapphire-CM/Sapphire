require 'rails_helper'

RSpec.describe EmailAddressesController do
  render_views
  include_context 'active_admin_session_context'

  let(:valid_attributes) do
    {
      email_address: {
        email: 'account@example.com',
      }
    }
  end

  let(:invalid_attributes) do
    {
      email_address: {
        email: 'invalid_account.com',
      }
    }
  end

  let(:account) { FactoryGirl.create :account }
  let(:email_address) { FactoryGirl.create :email_address, account: account }

  describe 'GET index' do
    it 'assigns all accounts as @accounts' do
      FactoryGirl.create_list :email_address, 4, account: account

      get :index, params: { account_id: account.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:email_addresses)).to eq(account.email_addresses)
    end
  end

  describe 'GET new' do
    it 'assigns a new email_address as @email_address' do
      get :new, params: { account_id: account.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:email_address)).to be_a_new(EmailAddress)
      expect(assigns(:email_address).account).to eq(account)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new EmailAddress' do
        valid_attributes[:account_id] = account.id

        expect do
          post :create, params: valid_attributes
        end.to change(EmailAddress, :count).by(1)

        expect(response).to redirect_to(account_email_addresses_path(account))
        expect(assigns(:email_address)).to be_a(EmailAddress)
        expect(assigns(:email_address)).to be_persisted
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved email_address as @email_address' do
        invalid_attributes[:account_id] = account.id

        post :create, params: invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:new)
        expect(assigns(:email_address)).to be_a_new(EmailAddress)
      end
    end
  end

  describe 'GET edit' do
    it 'assigns the requested email_address as @email_address' do
      get :edit, params: { account_id: account.id, id: email_address.id }

      expect(response).to have_http_status(:success)
      expect(assigns(:account)).to eq(account)
      expect(assigns(:email_address)).to eq(email_address)
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested email_address' do
        valid_attributes[:account_id] = account.id
        valid_attributes[:id] = email_address.id

        put :update, params: valid_attributes

        email_address.reload
        expect(response).to redirect_to(account_email_addresses_path(account))
        expect(email_address.email).to eq valid_attributes[:email_address][:email]
      end
    end

    describe 'with invalid params' do
      it 'assigns the requested email_address as @email_address' do
        invalid_attributes[:account_id] = account.id
        invalid_attributes[:id] = email_address.id

        put :update, params: invalid_attributes

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:edit)
        expect(assigns(:email_address)).to eq(email_address)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested email_address' do
      email_address.reload # trigger creation

      expect do
        delete :destroy, params: { account_id: account.id, id: email_address.id }
      end.to change(EmailAddress, :count).by(-1)

      expect(response).to redirect_to(account_email_addresses_path(account))
    end
  end
end
