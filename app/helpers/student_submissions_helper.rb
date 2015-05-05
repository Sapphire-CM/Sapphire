require 'zip'
require 'base64'

module StudentSubmissionsHelper
  def extract_filelist(archive)
    filelist = []
    Zip::File.open(archive) do |zip_file|
      zip_file.each do |entry|
        filename = entry.name.force_encoding('utf-8')
        if SubmissionAsset::EXCLUDED_FILTER.all? { |e| filename !~ e }
          id = Base64.encode64(entry.name).strip
          filelist << { id: id, filename: filename, size: entry.size }
        end
      end
    end
    filelist
  end
end
