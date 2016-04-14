require 'rails_helper'

RSpec.describe CoursePolicy do
  let(:course) { FactoryGirl.create(:course) }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    describe 'collections' do
      subject { described_class.new(account, nil) }

      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      subject { described_class.new(account, course) }

      it { is_expected.to permit_authorization(:new) }
      it { is_expected.to permit_authorization(:create) }
      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
      it { is_expected.to permit_authorization(:destroy) }
    end
  end

  context 'as not an admin' do
    let(:account) { FactoryGirl.create(:account, admin: false) }

    describe 'collections' do
      subject { described_class.new(account, nil) }

      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      subject { described_class.new(account, course) }

      it { is_expected.not_to permit_authorization(:new) }
      it { is_expected.not_to permit_authorization(:create) }
      it { is_expected.not_to permit_authorization(:edit) }
      it { is_expected.not_to permit_authorization(:update) }
      it { is_expected.not_to permit_authorization(:destroy) }
    end
  end
end
