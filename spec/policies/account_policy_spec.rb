require 'rails_helper'

RSpec.describe AccountPolicy do
  let(:another_account) { FactoryBot.create(:account, :student) }

  shared_examples "basic account permissions" do
    describe 'own account' do
      subject { AccountPolicy.new(current_account, current_account) }

      it { is_expected.to permit_authorization(:show) }
      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
      it { is_expected.to permit_authorization(:change_password) }
      it { is_expected.to permit_authorization(:update_password) }
    end
  end

  shared_examples "granted general account permissions" do
    describe 'collections' do
      subject { AccountPolicy.new(current_account, nil) }

      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      let(:account) { FactoryBot.create(:account) }
      subject { AccountPolicy.new(current_account, account) }

      it { is_expected.to permit_authorization(:show) }
      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
      it { is_expected.to permit_authorization(:destroy) }
      it { is_expected.to permit_authorization(:change_password) }
      it { is_expected.to permit_authorization(:update_password) }
    end
  end


  shared_examples "restricted general account permissions" do
    describe 'collections' do
      subject { AccountPolicy.new(current_account, nil) }

      it { is_expected.not_to permit_authorization(:index) }
    end

    describe 'members' do
      let(:account) { FactoryBot.create(:account) }
      subject { AccountPolicy.new(current_account, account) }

      it { is_expected.not_to permit_authorization(:show) }
      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:edit) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
      it { is_expected.not_to permit_authorization(:change_password) }
      it { is_expected.not_to permit_authorization(:update_password) }
    end
  end

  context 'as an admin' do
    let(:current_account) { FactoryBot.create(:account, :admin) }

    it_behaves_like "basic account permissions"
    it_behaves_like "granted general account permissions"
  end

  context 'as a lecturer' do
    let(:current_account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :lecturer, account: current_account) }

    it_behaves_like "basic account permissions"
    it_behaves_like "granted general account permissions"
  end

  context 'as a tutor' do
    let(:current_account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :tutor, account: current_account) }

    it_behaves_like "basic account permissions"
    it_behaves_like "restricted general account permissions"
  end

  context 'as a student' do
    let(:current_account) { FactoryBot.create(:account) }
    let!(:term_registration) { FactoryBot.create(:term_registration, :student, account: current_account) }

    it_behaves_like "basic account permissions"
    it_behaves_like "restricted general account permissions"
  end
end
