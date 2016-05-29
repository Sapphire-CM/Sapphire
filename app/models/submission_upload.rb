class SubmissionUpload
  include ActiveModel::Model

  attr_accessor :submission, :submitter, :path, :file
  attr_writer :submission_asset

  delegate :term, :students, :exercise, to: :submission
  delegate :errors, :valid?, to: :submission_asset

  def initialize(options = {})
    super
    @add_to_path = true
  end

  def save
    if save_asset
      track_event!
      schedule_extraction! if archive_upload?

      true
    else
      false
    end
  end

  def submission_asset
    @submission_asset ||= SubmissionAsset.new
  end

  private

  def save_asset
    sa = submission_asset
    sa.submission = submission
    sa.file = file if file.present?

    if path.present?
      sa.path = path
    else
      sa.path = ""
    end

    sa.save
  end

  def archive_upload?
    submission_asset.content_type == SubmissionAsset::Mime::ZIP
  end

  def schedule_extraction!
    ZipExtractionJob.perform_later(submission_asset)
  end

  def track_event!
    event_service = EventService.new(submitter, term)
    event_service.submission_asset_uploaded!(submission_asset)
  end
end
