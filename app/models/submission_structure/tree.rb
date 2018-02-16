class SubmissionStructure::Tree
  include ActiveModel::Model

  attr_accessor :submission, :base_directory_name

  delegate :submission_assets, to: :submission
  delegate :resolve, to: :base_dir

  def base_dir
    @base_dir ||= parse_submission
  end

  private

  class Parser
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

  def parse_submission
    parser = Parser.new(base_directory_name)
    submission_assets.each do |submission_asset|
      parser << submission_asset
    end
    parser.base_dir
  end
end