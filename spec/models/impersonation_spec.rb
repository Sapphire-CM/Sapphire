require "rails_helper"

RSpec.describe Impersonation do
  let(:warden) { double }
  let(:session) { Hash.new.with_indifferent_access }
  let(:current_account) { FactoryGirl.build(:account) }

  subject { described_class.new(warden: warden, session: session, current_account: current_account) }

  describe 'initialization' do
    it 'assigns attributes' do
      model = described_class.new(warden: warden, session: session, current_account: current_account)

      expect(model.warden).to eq(warden)
      expect(model.session).to eq(session)
      expect(model.current_account).to eq(current_account)
    end
  end

  describe '#impersonate' do
    let(:account) { FactoryGirl.build(:account) }

    before :each do
      allow(subject).to receive(:sign_in).and_return(true)
    end

    it "calls sign_in with passed account" do
      expect(subject).to receive(:sign_in).with(:account, account).and_return(true)

      subject.impersonate account
    end

    it "sets :impersonator_id on session" do
      current_account.save
      expect(current_account.id).to be_present

      subject.impersonate account

      expect(session[:impersonator_id]).to eq(current_account.id)
    end

    it "does not change :impersonator_id on session if it is already present" do
      session[:impersonator_id] = "fancy id"

      subject.impersonate account

      expect(session[:impersonator_id]).to eq("fancy id")
    end
  end

  describe '#destroy' do
    let(:admin_account) { FactoryGirl.create(:account, :admin) }

    before :each do
      session[:impersonator_id] = admin_account.id
      allow(subject).to receive(:sign_in).and_return(true)
    end

    it "signs in with the impersonator account" do
      expect(subject).to receive(:sign_in).with(:account, admin_account).and_return(true)

      subject.destroy
    end

    it "clears :impersonator_id on session" do
      subject.destroy

      expect(session[:impersonator_id]).to be_nil
    end
  end
end
