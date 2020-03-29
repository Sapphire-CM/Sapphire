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
#   t.integer  :processed_size,    default: 0
#   t.integer  :filesystem_size,   default: 0
#   t.integer  :extraction_status
#   t.integer  :submitter_id,                   null: false
# end
#
# add_index :submission_assets, [:filename, :path, :submission_id], name: :index_submission_assets_on_filename_and_path_and_submission_id, unique: true
# add_index :submission_assets, [:submission_id], name: :index_submission_assets_on_submission_id
# add_index :submission_assets, [:submitter_id], name: :index_submission_assets_on_submitter_id

require "charlock_holmes"

class SubmissionAsset < ActiveRecord::Base
  belongs_to :submission, touch: true
  belongs_to :submitter, class_name: 'Account', foreign_key: 'submitter_id'
  mount_uploader :file, SubmissionAssetUploader

  enum extraction_status: [:extraction_pending, :extraction_in_progress, :extraction_done, :extraction_failed]

  validates :submission, presence: true
  validates :file, presence: true
  validate :filename_uniqueness_validation
  validate :filesize_validation
  validate :archive_structure_validation, if: :archive?

  before_save :set_submitted_at, if: :file_changed?, unless: :submitted_at
  before_validation :set_content_type, if: :file_changed?
  before_validation :set_filesizes, if: :file_changed?
  before_validation :set_filename, if: :file_changed?
  before_validation :set_normalized_path, if: :path_changed?
  before_validation :set_default_extraction_status, if: :archive?

  scope :stylesheets, lambda { where(content_type: Mime::STYLESHEET) }
  scope :htmls, lambda { where(content_type: Mime::HTML) }
  scope :images, lambda { where { content_type.in(Mime::IMAGES) } }
  scope :pdfs, lambda { where { content_type.in(Mime::PDF) } }
  scope :archives, lambda { where { content_type.in(Mime::ARCHIVES) } }

  scope :for_exercise, lambda { |exercise| joins(:submission).where(submissions: { exercise_id: exercise.id }) }
  scope :for_term, lambda { |term| joins(submission: :exercise).where(submission: { exercise: { term: term } }) }

  delegate :exercise, to: :submission

  after_save :add_to_submission_filsize
  after_destroy :remove_from_submission_filesize

  EXCLUDED_FILTER = [
    # no operating system meta data files
    %r{Thumbs\.db}i.freeze,
    %r{desktop\.ini}i.freeze,
    %r{\.DS_Store}i.freeze,
    %r{\.directory}i.freeze,
    %r{\A__MACOSX/}i.freeze,
    %r{\._.*}i.freeze,

    # no version control files
    %r{\.svn/}i.freeze,
    %r{\.git/}i.freeze,
    %r{\.hg/}i.freeze,

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
    ARCHIVES = [ZIP]
  end

  def self.at_path_components(path)
    path = normalize_path(path)

    components = extract_path_components(path)

    scope = all

    or_clauses = []
    or_values = []

    components.each do |component|
      dirname = File.dirname(component)
      dirname = "" if dirname == "."

      or_clauses << "(path = ? AND filename = ?)"
      or_values += [dirname, File.basename(component)]
    end

    or_clauses << "(path LIKE ?)"
    or_values << "#{path}/%"

    or_clauses << "(path = ?)"
    or_values << path

    where(or_clauses.join(" OR "), *or_values)
  end

  def self.path_exists?(path)
    at_path_components(path).exists?
  end

  def self.inside_path(unnormalized_path)
    normalized_path = normalize_path(unnormalized_path)

    where { path =~ my {"#{normalized_path}%"} }
  end

  def self.normalize_path(path)
    Pathname.new(path.to_s.presence || "").cleanpath.to_s.gsub(/\A\/+|\/+\z/, "").gsub(/\/+/, "/").gsub(/(\.\.\/)+/, "").gsub(/^\.$/, "")
  end

  def complete_path
    return "" unless filename.present?

    File.join(*([path.presence, filename].compact))
  end

  def set_submitted_at
    self.submitted_at = Time.now
  end

  def set_content_type
    if file.to_s.present? && type = MIME::Types.type_for(file.to_s).first
      self.content_type = type.content_type
    end
  end

  def set_filesizes
    self.filesystem_size = file.file.try(:size) || 0

    if self.archive?
      self.processed_size = extracted_archive_size
    else
      self.processed_size = self.filesystem_size
    end
  end

  def set_filename
    self.filename = File.basename file.to_s
  end

  def set_default_extraction_status
    self.extraction_status = :extraction_pending
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

  def set_normalized_path
    self.path = self.class.normalize_path(path)
  end

  def archive?
    Mime::ARCHIVES.include? self.content_type
  end

  private

  def self.extract_path_components(path)
    components = []
    Pathname.new(path).descend do |component|
      components << component
    end
    components
  end

  def extracted_archive_size
    extractor = SubmissionExtractionService.new(self)
    extractor.accumulated_filesize
  end

  def filename_uniqueness_validation
    full_path = File.join(*([self.path, self.filename].map(&:presence).compact))

    scope = SubmissionAsset.at_path_components(full_path).where(submission: submission)
    scope = scope.where.not(id: id) if persisted?

    if scope.exists?
      errors.add(:filename, "has already been taken")
      errors.add(:file, "already exists")
    end
  end

  def filesize_validation
    return unless submission.present?
    submission_assets_scope = submission.submission_assets
    submission_assets_scope = submission_assets_scope.where.not(id: self.id) if persisted?

    if exercise.present? && exercise.enable_max_upload_size && (submission_assets_scope.sum(:processed_size) + self.processed_size) > exercise.maximum_upload_size
      if archive?
        errors.add(:file, 'exceeds maximum upload size after extraction')
      else
        errors.add(:file, 'exceeds maximum upload size')
      end
    end
  end

  def archive_structure_validation
    begin
      Zip::File.open(self.file.to_s)
      true
    rescue Zip::Error
      errors.add(:file, "is not an archive")
    end
    true
  end

  def add_to_submission_filsize
    submission.update('filesystem_size' => (filesystem_size + submission.filesystem_size))
    submission.exercise.update('filesystem_size' => (filesystem_size + submission.exercise.filesystem_size))
  end

  def remove_from_submission_filesize
    submission.update('filesystem_size' => (submission.filesystem_size - filesystem_size))
    submission.exercise.update('filesystem_size' => (submission.exercise.filesystem_size - filesystem_size))   
  end
end
