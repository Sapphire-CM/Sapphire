require 'rails_helper'

RSpec.describe AccountPolicy do
  let(:another_account) { FactoryGirl.create(:account, :student) }

  context 'as an admin' do
    let(:current_account) { FactoryGirl.create(:account, :admin) }

    describe 'collections' do
      subject { AccountPolicy.new(current_account, nil) }

      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      subject { AccountPolicy.new(current_account, another_account) }

      it { is_expected.to permit_authorization(:show) }
      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
      it { is_expected.to permit_authorization(:destroy) }
      it { is_expected.to permit_authorization(:change_password) }
      it { is_expected.to permit_authorization(:update_password) }
    end
  end

  context 'as an ordinanary user' do
    let(:current_account) { FactoryGirl.create(:account) }

    describe 'collections' do
      subject { AccountPolicy.new(current_account, nil) }

      it { is_expected.not_to permit_authorization(:index) }
    end

    describe 'members' do
      describe 'own account' do
        subject { AccountPolicy.new(current_account, current_account) }

        it { is_expected.to permit_authorization(:show) }
        it { is_expected.to permit_authorization(:edit) }
        it { is_expected.to permit_authorization(:update) }
        it { is_expected.not_to permit_authorization(:destroy) }
        it { is_expected.to permit_authorization(:change_password) }
        it { is_expected.to permit_authorization(:update_password) }
      end

      describe 'another account' do
        subject { AccountPolicy.new(current_account, another_account) }

        it { is_expected.not_to permit_authorization(:show) }
        it { is_expected.not_to permit_authorization(:edit) }
        it { is_expected.not_to permit_authorization(:update) }
        it { is_expected.not_to permit_authorization(:destroy) }
        it { is_expected.not_to permit_authorization(:change_password) }
        it { is_expected.not_to permit_authorization(:update_password) }
      end
    end
  end
end
