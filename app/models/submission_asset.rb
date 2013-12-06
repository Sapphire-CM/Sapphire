class SubmissionAsset < ActiveRecord::Base
  belongs_to :submission
  mount_uploader :file, SubmissionAssetUploader

  validates_presence_of :file, :submission

  attr_accessible :file, :submission_id

  scope :stylesheets, lambda { where(content_type: Mime::STYLESHEET)}
  scope :htmls, lambda { where(content_type: Mime::HTML)}
  scope :images, lambda { where{content_type.in(Mime::IMAGES)} }


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



end
