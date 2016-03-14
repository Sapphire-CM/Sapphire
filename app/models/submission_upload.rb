class SubmissionUpload
  include ActiveModel::Model

  attr_accessor :submission, :path, :file
  attr_reader :add_to_path

  delegate :term, :students, to: :submission
  delegate :errors, :valid?, to: :submission_asset

  def initialize(options = {})
    super
    @add_to_path = true
  end

  def save
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

  def submission_asset
    @submission_asset ||= SubmissionAsset.new
  end
end
