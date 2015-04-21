class SubmissionAsset < ActiveRecord::Base
  belongs_to :submission
  mount_uploader :file, SubmissionAssetUploader

  validates :submission, presence: true
  validates :file, presence: true

  before_save :update_submitted_at, if: :file_changed?

  scope :stylesheets, lambda { where(content_type: Mime::STYLESHEET) }
  scope :htmls, lambda { where(content_type: Mime::HTML) }
  scope :images, lambda { where { content_type.in(Mime::IMAGES) } }
  scope :pdfs, lambda { where { content_type.in(Mime::PDF) } }
  scope :archives, lambda { where { content_type.in(Mime::ZIP) } }

  scope :for_exercise, lambda { |exercise| joins(:submission).where(submissions: { exercise_id: exercise.id }) }

  delegate :submitter, to: :submission

  after_save :set_content_type!

  EXCLUDED_FILTER = [
    # no operating system meta data files
    %r{Thumbs.db}i,
    %r{desktop.ini}i,
    %r{.DS_Store}i,
    %r{\A__MACOSX/}i,

    # no version control files
    %r{.svn/}i,
    %r{.git/}i,
    %r{.hg/}i,

    # no plain folders
    %r{/$}i,
  ]

  class Mime
    NEWSGROUP_POST = 'text/newsgroup'
    EMAIL = 'text/email'
    STYLESHEET = 'text/css'
    HTML = 'text/html'
    JPEG = 'image/jpeg'
    PNG = 'image/png'
    ZIP = 'application/zip'
    PLAIN_TEXT = 'text/plain'
    FAVICON = 'image/x-icon'
    PDF = 'application/pdf'

    IMAGES = [JPEG, PNG]
  end

  def filesize
    file.file.try(:size) || 0
  end

  def update_submitted_at
    self.submitted_at = Time.now
  end

  def set_content_type!
    update! content_type: MIME::Types.type_for(file.to_s).first.content_type if content_type.blank?
  end
end
