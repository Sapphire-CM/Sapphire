require "zip"

class SubmissionExtractionService
  include EventSourcing

  class ExtractionError < StandardError; end

  attr_accessor :submission_asset, :created_assets, :errors

  def initialize(submission_asset)
    self.submission_asset = submission_asset
    self.created_assets = []
    self.errors = []
  end

  def submission
    @submission ||= submission_asset.submission
  end

  def perform!
    processed_size = submission_asset.processed_size

    begin
      # needs to be reset, in order to allow correct file-size validation
      submission_asset.processed_size = 0
      submission_asset.save(validate: false)

      extract_zip!
      remove_archive_asset!
      # create_event!

    rescue ExtractionError
      submission_asset.extraction_status = :extraction_failed
      submission_asset.processed_size = processed_size
      submission_asset.save(validate: false)
    ensure
    end
  end

  def accumulated_filesize
    accumulated_size = 0
    Zip::File.open(submission_asset.file.to_s) do |zip_file|
      accumulated_size = filter_zip_entries(zip_file).map(&:size).sum
    end
    accumulated_size
  rescue Zip::Error
    0
  end

  private

  def extract_zip!
    self.created_assets = []
    self.errors = []
    Zip::File.open(submission_asset.file.to_s) do |zip_file|
      filter_zip_entries(zip_file).each do |entry|
        entry_name = utf8_filename(entry.name)

        zip_path, filename = File.split(entry_name)
        zip_path = '' if zip_path == '.'

        extraction_directory = File.join(Dir.tmpdir, zip_path)
        FileUtils.mkdir_p extraction_directory

        destination = File.join extraction_directory, filename
        zip_file.extract entry, destination

        asset_path = File.join(submission_asset.path, zip_path)

        submission_asset = submission.submission_assets.create(file: File.open(destination), path: asset_path)

        unless submission_asset.valid?
          self.errors << submission_asset.errors
        else
          self.created_assets << submission_asset
        end
      end
    end
    raise ExtractionError unless self.errors.empty?
  end

  def filter_zip_entries(zip_file)
    zip_file.select do |entry|
      entry_name = utf8_filename(entry.name)

      SubmissionAsset::EXCLUDED_FILTER.all? {|e| entry_name !~ e }
    end
  end

  def utf8_filename(filename)
    filename.clone.encode('UTF-8', invalid: :replace, undef: :replace, replace: '_')
  end

  def remove_archive_asset!
    submission_asset.destroy
  end

  def create_event!
    event_service.submission_extracted!(submission, submission_assets, new_submission_assets)
  end

  def current_term
    self.submission_asset.submission.exercise.term
  end

  def current_account
    self.submission_asset.submitter
  end
end
