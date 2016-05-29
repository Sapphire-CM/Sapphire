require 'rails_helper'

RSpec.describe ImpersonationsController, type: :controller do
  include_context 'active_admin_session_context'

  let(:other_account) { FactoryGirl.create(:account) }
  let!(:impersonation) { Impersonation.new }

  before :each do
    allow(Impersonation).to receive(:new) do |params|
      # from active model::initialize
      params.each do |attr, value|
        impersonation.public_send("#{attr}=", value)
      end if params

      impersonation
    end
  end

  describe 'POST #create' do
    before :each do
      allow(impersonation).to receive(:impersonate).with(other_account).and_return(true)
    end

    context "with valid params" do
      it 'impersonates given account' do
        expect(impersonation).to receive(:impersonate).with(other_account).and_return(true)

        post :create, account_id: other_account.id
      end

      it 'redirects to root_path' do
        post :create, account_id: other_account.id

        expect(response).to redirect_to(root_path)
      end
    end

    context "with invalid params" do
      let(:non_admin_account) { FactoryGirl.create(:account, admin: false) }

      it "does not raise an error" do
        expect do
          post :create, account_id: "does not exist"
        end.not_to raise_error

        expect(response).to render_template("record_not_found")
      end

      it "prohibits unauthorized access" do
        sign_in(non_admin_account)

        expect(impersonation).not_to receive(:impersonate)

        post :create, account_id: other_account.id
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:admin_account) { FactoryGirl.create(:account) }

    it 'removes impersonation' do
      session[:impersonator_id] = admin_account.id
      expect(impersonation).to receive(:sign_in).with(:account, admin_account)

      delete :destroy
      expect(subject.instance_variable_get("@impersonation")).to eq(impersonation)
    end

    it 'fails silently, if no :impersonator_id is set' do
      session[:impersonator_id] = nil

      delete :destroy

      expect(session["flash"]).to be_blank
    end
  end
end
