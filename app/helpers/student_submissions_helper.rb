require 'zip'
require 'base64'

module StudentSubmissionsHelper
  def extract_filelist(archive)
    filelist = []
    Zip::File.open(archive) do |zip_file|
      zip_file.each do |entry|
        if SubmissionAsset::EXCLUDED_FILTER.map { |e| entry.name !~ e }.all?
          id = Base64.encode64(entry.name).strip
          filename = entry.name.force_encoding('utf-8')
          filelist << { id: id, filename: filename, size: entry.size }
        end
      end
    end
    filelist
  end
end
