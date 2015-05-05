require 'zip'
require 'base64'

module StudentSubmissionsHelper
  def encode_filename(filename)
    filename.clone.encode('UTF-8', invalid: :replace, undef: :replace, replace: '_')
  end

  def extract_filelist(archive)
    filelist = []
    Zip::File.open(archive) do |zip_file|
      zip_file.each do |entry|
        filename = encode_filename(entry.name)
        if SubmissionAsset::EXCLUDED_FILTER.all? { |e| filename !~ e }
          id = Base64.encode64(entry.name).strip
          filelist << { id: id, filename: filename, size: entry.size }
        end
      end
    end
    filelist
  end
end
