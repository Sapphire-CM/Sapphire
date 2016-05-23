class SubmissionUpload
  include ActiveModel::Model

  attr_accessor :submission, :path, :file

  delegate :term, :students, :exercise, to: :submission
  delegate :errors, :valid?, to: :submission_asset

  def initialize(options = {})
    super
    @add_to_path = true
  end

  def save
    if save_asset
      schedule_extraction! if archive_upload?
      create_or_update_event!

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

  def create_or_update_event!
    # pending
  end
end
