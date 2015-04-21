require 'zip'

module StudentSubmissionsHelper
  def extract_filelist(archive)
    filelist = []
    Zip::File.open(archive) do |zip_file|
      zip_file.each do |entry|
        if SubmissionAsset::EXCLUDED_FILTER.map { |e| entry.name !~ e }.all?
          filelist << [entry.name, entry.size]
        end
      end
    end
    filelist
  end
end
