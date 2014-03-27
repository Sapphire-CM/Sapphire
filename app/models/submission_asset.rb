class SubmissionAsset < ActiveRecord::Base
  belongs_to :submission
  mount_uploader :file, SubmissionAssetUploader

  validates_presence_of :file, :submission
  before_save :update_submitted_at, if: :file_changed?

  scope :stylesheets, lambda { where(content_type: Mime::STYLESHEET)}
  scope :htmls, lambda { where(content_type: Mime::HTML)}
  scope :images, lambda { where{content_type.in(Mime::IMAGES)} }

  delegate :submitter, to: :submission

  class Mime
    NEWSGROUP_POST = "text/newsgroup"
    EMAIL = "text/email"
    STYLESHEET = "text/css"
    HTML = "text/html"
    JPEG = "image/jpeg"
    PNG = "image/png"
    FAVICON = "image/x-icon"

    IMAGES = [JPEG, PNG]
  end

  def filesize
    file.file.size
  end

  def update_submitted_at
    self.submitted_at = Time.now
  end
end
