require "zip"

class SubmissionExtractionService
  include EventSourcing
  attr_accessor :submission_asset, :created_assets

  def initialize(submission_asset)
    self.submission_asset = submission_asset
    self.created_assets = []
  end

  def submission
    @submission ||= submission_asset.submission
  end

  def perform!
    extract_zip!
    remove_archive_asset!
    create_event!
  end

  private

  def extract_zip!
    self.created_assets = []
    Zip::File.open(submission_asset.file.to_s) do |zip_file|
      zip_file.each do |entry|
        entry_name = utf8_filename(entry.name)
        next if SubmissionAsset::EXCLUDED_FILTER.any? { |e| entry_name =~ e }

        zip_path, filename = File.split(entry_name)
        zip_path = '' if zip_path == '.'

        extraction_directory = File.join(Dir.tmpdir, zip_path)
        FileUtils.mkdir_p extraction_directory

        destination = File.join extraction_directory, filename
        zip_file.extract entry, destination

        asset_path = File.join(submission_asset.path, zip_path)

        self.created_assets << submission.submission_assets.create!(file: File.open(destination), path: asset_path)
      end
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
