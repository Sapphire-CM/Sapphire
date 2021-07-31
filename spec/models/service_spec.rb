require 'rails_helper'

RSpec.describe Service do
  describe 'db columns' do
    it { is_expected.to have_db_column(:active).of_type(:boolean).with_options(default: false, null: false) }
    it { is_expected.to have_db_column(:type).of_type(:string) }
    it { is_expected.to have_db_column(:properties).of_type(:text) }

    it { is_expected.to have_db_column(:created_at).of_type(:datetime).with_options(null: false) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime).with_options(null: false) }
  end

  describe 'inheritance' do
    describe 'SerializedProperties' do
      it 'is included' do
        expect(subject).to be_a(SerializedProperties)
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:exercise) }
    it { is_expected.to have_one(:term).through(:exercise) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:exercise_id) }
    it { is_expected.to validate_exclusion_of(:type).in_array(["Service"]) }
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_services) { FactoryBot.create_list(:website_fetcher_service, 2, :active) }
      let!(:inactive_services) { FactoryBot.create_list(:website_fetcher_service, 2, :inactive) }

      it 'returns active services' do
        expect(described_class.active).to match_array(active_services)
      end
    end
  end

  describe 'methods' do
    describe '.service_classes' do
      it 'returns the instantiable subclasses' do
        expect(described_class.service_classes).to match_array([Services::NewsgroupFetcherService, Services::WebsiteFetcherService])
      end
    end

    describe '.policy_class' do
      it 'returns ServicePolicy' do
        expect(described_class.policy_class).to eq(ServicePolicy)
      end
    end

    describe '#title' do
      it 'returns raises an error' do
        expect do
          subject.title
        end.to raise_error(NotImplementedError)
      end
    end

    describe '#perform!' do
      it 'returns raises an error' do
        expect do
          subject.perform!
        end.to raise_error(NotImplementedError)
      end
    end
  end
end