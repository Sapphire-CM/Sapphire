require 'zip'

module StudentSubmissionsHelper
  def extract_filelist(archive)
    filelist = []
    Zip::File.open(archive) do |zip_file|
      zip_file.each do |entry|
        excluded = [
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

        if excluded.map { |e| entry.name !~ e }.all?
          filelist << entry.name
        end
      end
    end
    filelist
  end
end
