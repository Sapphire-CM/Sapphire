require 'rails_helper'

RSpec.describe ZipExtractionJob, type: :job do
  let(:submission_asset) { FactoryBot.build(:submission_asset) }
  let(:extraction_service) { instance_double(SubmissionExtractionService) }

  describe '#perform' do
    it 'extracts zips via the SubmissionExtractionService' do
      allow(SubmissionExtractionService).to receive(:new).with(submission_asset).and_return(extraction_service)
      expect(extraction_service).to receive(:perform!).and_return(true)

      subject.perform(submission_asset)
    end
  end
end
