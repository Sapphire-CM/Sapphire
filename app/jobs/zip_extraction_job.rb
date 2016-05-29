class ZipExtractionJob < ActiveJob::Base
  queue_as :default

  def perform(submission_asset)
    extractor = SubmissionExtractionService.new(submission_asset)
    extractor.perform!
  end
end
