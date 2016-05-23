require "rails_helper"

RSpec.describe SubmissionExtractionService do
  describe 'initialization' do
    let(:submission_asset) { FactoryGirl.build(:submission_asset) }

    it 'requires a submission_asset as parameter' do
      service = nil
      expect do
        service = described_class.new(submission_asset)
      end.not_to raise_error

      expect(service.submission_asset).to eq(submission_asset)
    end

    it 'sets default values' do
      service = described_class.new(submission_asset)

      expect(service.errors).to eq([])
      expect(service.created_assets).to eq([])
    end
  end

  describe '#perform' do
    context 'with valid ZIP archive' do
      it 'extracts zip asset'
      it 'creates a event'
      it 'removes zip asset, if extraction succeeded'
    end

    context 'with invalid ZIP archive' do
      it 'checks if the asset is a zip archive'
      it 'sets errors for failed submission assets'
      it 'does create an event indicating failed extraction'
      it 'does not remove asset if errors occured'
    end
  end

  describe '#accumulated_filesize' do
    it 'returns the sum of filesizes after extracting all files'
  end
end
