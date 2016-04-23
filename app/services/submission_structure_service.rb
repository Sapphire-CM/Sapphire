class SubmissionStructureService
  class FileDoesNotExist < ArgumentError; end

  def self.parse_submission(submission, root_directory_name = "/")
    parse_structure(submission.submission_assets, root_directory_name)
  end

  private
  def self.parse_structure(submission_assets, root_directory_name)
    parser = DirectoryTreeParser.new(root_directory_name)

    submission_assets.each do |submission_asset|
      parser << submission_asset
    end

    parser.base_dir
  end

  class DirectoryTreeParser
    attr_reader :base_dir

    def initialize(root_directory_name)
      @base_dir = ::SubmissionStructure::Directory.new(root_directory_name)
    end

    def <<(submission_asset)
      path = submission_asset.path

      directories = split_path path

      current_dir = @base_dir
      while dir = directories.shift
        next_dir = current_dir[dir]

        if next_dir.nil?
          next_dir = ::SubmissionStructure::Directory.new(dir)
          current_dir << next_dir
        end

        current_dir = next_dir
      end

      current_dir << ::SubmissionStructure::File.new(submission_asset)
    end

    def filesize
      @base_dir.filesize
    end

    def updated_at
      @base_dir.updated_at
    end

    private
    def split_path(path)
      Pathname(path).each_filename.to_a
    end
  end
end
