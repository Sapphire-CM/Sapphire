require "charlock_holmes"

class SubmissionAsset < ActiveRecord::Base
  belongs_to :submission, inverse_of: :submission_assets
  mount_uploader :file, SubmissionAssetUploader

  validates :submission, presence: true
  validates :file, presence: true

  before_save :set_submitted_at, if: :file_changed?
  before_save :set_content_type, if: :file_changed?

  scope :stylesheets, lambda { where(content_type: Mime::STYLESHEET) }
  scope :htmls, lambda { where(content_type: Mime::HTML) }
  scope :images, lambda { where { content_type.in(Mime::IMAGES) } }
  scope :pdfs, lambda { where { content_type.in(Mime::PDF) } }
  scope :archives, lambda { where { content_type.in(Mime::ZIP) } }

  scope :for_exercise, lambda { |exercise| joins(:submission).where(submissions: { exercise_id: exercise.id }) }

  delegate :submitter, to: :submission

  EXCLUDED_FILTER = [
    # no operating system meta data files
    %r{Thumbs.db}i,
    %r{desktop.ini}i,
    %r{.DS_Store}i,
    %r{.directory}i,
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

  def set_submitted_at
    self.submitted_at = Time.now
  end

  def set_content_type
    if file.to_s.present? && type = MIME::Types.type_for(file.to_s).first
      self.content_type = type.content_type
    end
  end

  def utf8_contents
    contents = file.read
    detection = CharlockHolmes::EncodingDetector.detect(contents)

    CharlockHolmes::Converter.convert contents, detection[:encoding], 'UTF-8'
  end
end
