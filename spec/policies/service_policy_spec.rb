require 'rails_helper'

RSpec.describe ServicePolicy do
  let(:exercise) { FactoryGirl.create(:exercise, term: term) }
  let(:service) { FactoryGirl.create(:service, exercise: exercise) }
  let(:term) { FactoryGirl.create(:term) }

  context 'as an admin' do
    let(:account) { FactoryGirl.create(:account, :admin) }

    describe 'collections' do
      subject { ServicePolicy.new(account, term) }

      it { is_expected.to permit_authorization(:index) }
    end

    describe 'members' do
      subject { ServicePolicy.new(account, service) }

      it { is_expected.to permit_authorization(:edit) }
      it { is_expected.to permit_authorization(:update) }
    end
  end

  context 'as a lecturer' do
    let(:account) { FactoryGirl.create(:account) }

    context 'of a lecturered term' do
      let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, term: term, account: account) }

      describe 'collections' do
        subject { ServicePolicy.new(account, term) }

        it { is_expected.to permit_authorization(:index) }
      end

      describe 'members' do
        subject { ServicePolicy.new(account, service) }

        it { is_expected.to permit_authorization(:edit) }
        it { is_expected.to permit_authorization(:update) }
      end
    end

    context 'of another term' do
      let!(:term_registration) { FactoryGirl.create(:term_registration, :lecturer, account: account) }

      describe 'collections' do
        subject { ServicePolicy.new(account, term) }

        it { is_expected.not_to permit_authorization(:index) }
      end

      describe 'members' do
        subject { ServicePolicy.new(account, service) }

        it { is_expected.not_to permit_authorization(:edit) }
        it { is_expected.not_to permit_authorization(:update) }
      end
    end
  end

  %I(tutor student).each do |role|
    context "as a #{role}" do
      let(:account) { FactoryGirl.create(:account) }

      context 'of attended term' do
        let!(:term_registration) { FactoryGirl.create(:term_registration, role, account: account, term: term) }

        describe 'collections' do
          subject { ServicePolicy.new(account, term) }

          it { is_expected.not_to permit_authorization(:index) }
        end

        describe 'members' do
          subject { ServicePolicy.new(account, service) }

          it { is_expected.not_to permit_authorization(:edit) }
          it { is_expected.not_to permit_authorization(:update) }
        end
      end

      context 'of another term' do
        let!(:term_registration) { FactoryGirl.create(:term_registration, role, account: account) }

        describe 'collections' do
          subject { ServicePolicy.new(account, term) }

          it { is_expected.not_to permit_authorization(:index) }
        end

        describe 'members' do
          subject { ServicePolicy.new(account, service) }

          it { is_expected.not_to permit_authorization(:edit) }
          it { is_expected.not_to permit_authorization(:update) }
        end
      end
    end
  end
end
