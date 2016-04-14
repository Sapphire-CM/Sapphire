# create_table :submission_assets, force: :cascade do |t|
#   t.integer  :submission_id
#   t.string   :file
#   t.string   :content_type
#   t.datetime :submitted_at
#   t.datetime :created_at,                     null: false
#   t.datetime :updated_at,                     null: false
#   t.string   :asset_identifier
#   t.string   :import_identifier
#   t.string   :path,              default: ""
#   t.string   :filename
# end
#
# add_index :submission_assets, [:filename, :path, :submission_id], name: :index_submission_assets_on_filename_and_path_and_submission_id, unique: true
# add_index :submission_assets, [:submission_id], name: :index_submission_assets_on_submission_id

require "charlock_holmes"

class SubmissionAsset < ActiveRecord::Base
  belongs_to :submission, inverse_of: :submission_assets
  mount_uploader :file, SubmissionAssetUploader

  validates :submission, presence: true
  validates :file, presence: true
  validate :filename_uniqueness_validation

  before_save :set_submitted_at, if: :file_changed?
  before_save :set_content_type, if: :file_changed?
  before_validation :set_filename, if: :file_changed?
  before_validation :normalize_path!, if: :path_changed?

  scope :stylesheets, lambda { where(content_type: Mime::STYLESHEET) }
  scope :htmls, lambda { where(content_type: Mime::HTML) }
  scope :images, lambda { where { content_type.in(Mime::IMAGES) } }
  scope :pdfs, lambda { where { content_type.in(Mime::PDF) } }
  scope :archives, lambda { where { content_type.in(Mime::ZIP) } }

  scope :for_exercise, lambda { |exercise| joins(:submission).where(submissions: { exercise_id: exercise.id }) }
  scope :for_term, lambda { |term| joins(submission: :exercise).where(submission: { exercise: { term: term } }) }

  delegate :submitter, to: :submission

  EXCLUDED_FILTER = [
    # no operating system meta data files
    %r{Thumbs.db}i.freeze,
    %r{desktop.ini}i.freeze,
    %r{.DS_Store}i.freeze,
    %r{.directory}i.freeze,
    %r{\A__MACOSX/}i.freeze,

    # no version control files
    %r{.svn/}i.freeze,
    %r{.git/}i.freeze,
    %r{.hg/}i.freeze,

    # no plain folders
    %r{/$}i.freeze,
  ].freeze

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

  def self.path_exists?(path)
    dirname, basename = File.split(path)

    inside_path(path).exists? || inside_path(dirname).where(filename: basename).exists?
  end

  def self.inside_path(unnormalized_path)
    normalized_path = normalize_path(unnormalized_path)

    where { path =~ my {"#{normalized_path}%"} }
  end

  def filesize
    file.file.try(:size) || 0
  end

  def complete_path
    File.join(path, filename)
  end

  def set_submitted_at
    self.submitted_at = Time.now
  end

  def set_content_type
    if file.to_s.present? && type = MIME::Types.type_for(file.to_s).first
      self.content_type = type.content_type
    end
  end

  def set_filename
    self.filename = File.basename file.to_s
  end

  def utf8_contents
    contents = file.read

    if contents.blank?
      ''
    else
      detection = CharlockHolmes::EncodingDetector.detect(contents)

      if detection[:encoding].present?
        CharlockHolmes::Converter.convert contents, detection[:encoding], 'UTF-8'
      else
        ''
      end
    end
  end

  private

  def self.normalize_path(path)
    Pathname.new(path.presence || "").cleanpath.to_s.gsub(/\A\/+|\/+\z/, "").gsub(/\/+/, "/")
  end

  def filename_uniqueness_validation
    scope = SubmissionAsset.where(filename: filename, path: path, submission_id: submission_id)
    scope = scope.where.not(id: id) if persisted?

    if scope.exists?
      errors.add(:filename, "has already been taken")
      errors.add(:file, "already exists")
    end
  end

  def normalize_path!
    self.path = self.class.normalize_path(path)
  end
end
