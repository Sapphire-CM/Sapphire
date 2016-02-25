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
      @base_dir = Directory.new(root_directory_name)
    end

    def <<(submission_asset)
      path = submission_asset.path

      directories = split_path path

      current_dir = @base_dir
      while dir = directories.shift
        next_dir = current_dir[dir]

        if next_dir.nil?
          next_dir = Directory.new(dir)
          current_dir << next_dir
        end

        current_dir = next_dir
      end

      current_dir << File.new(submission_asset)
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

  class TreeNode
    attr_reader :name, :size, :mtime, :icon, :path
    attr_accessor :parent

    def directory?
      false
    end

    def file?
      false
    end

    def root?
      parent.blank?
    end

    def size
      0
    end

    def mtime
      nil
    end

    def icon
      ""
    end

    def path
      @path ||= root? ? name : ::File.join(parent.path, name)
    end

    def path_without_root
      ::File.join(*parents.reject(&:root?).map(&:name))
    end

    def relative_path
      if path[0] == "/"
        path[1..-1]
      else
        path
      end
    end

    def attributes
      {name: name, parent: parent}
    end

    def marshal_dump
      attributes
    end

    def marshal_load(attributes)
      self.name = attributes[:name]
      self.parent = attributes[:parent]
    end

    def path_components
      if path.present?
        Pathname(path).each_filename.to_a
      else
        []
      end
    end

    def parents
      ancestors + [self]
    end

    def ancestors
      return [] if root?

      entry = self
      parents = []
      while entry = entry.parent
        parents << entry
      end
      parents.reverse
    end
  end

  class Directory < TreeNode
    attr_reader :entries

    def initialize(name, parent = nil)
      @name = name
      @nodes = {}
    end

    def size
      entries.sum(&:size)
    end

    def <<(node)
      node.parent = self
      @nodes[node.name] = node
      self
    end

    def [](name)
      @nodes[name]
    end

    def resolve(path)
      name, path = Pathname(path).each_filename.to_a

      node = @nodes[name]

      if node
        if path.present?
          node.resolve(::File.join(*path))
        else
          node
        end
      else
        raise FileDoesNotExist.new("#{name}, #{path}, #{@nodes.keys}")
      end
    end

    def entries
      @nodes.values
    end

    def sorted_entries
      entries.sort_by(&:name)
    end

    def directory?
      true
    end

    def mtime
      entries.max(&:mtime)
    end

    def icon
      "folder"
    end

    def attributes
      super.merge nodes: @nodes
    end

    def attributes=(attributes)
      super
      @nodes = attributes[:nodes]
    end
  end

  class File < TreeNode
    attr_reader :icon, :size, :name, :mtime, :submission_asset

    def initialize(submission_asset, parent = nil)
      @icon = icon_for_submission_asset(submission_asset)
      @size = submission_asset.filesize
      @name = submission_asset.filename
      @mtime = submission_asset.updated_at
      @submission_asset = submission_asset
    end

    def file?
      true
    end

    def attributes
      super.merge icon: @icon, size: @size, mtime: @mtime
    end

    def attributes=(attributes)
      super
      @icon = attributes[:icon]
      @size = attributes[:size]
      @mtime = attributes[:mtime]
    end


    private
    def icon_for_submission_asset(submission_asset)
      case submission_asset.content_type
      when *SubmissionAsset::Mime::IMAGES
        "photo"
      when SubmissionAsset::Mime::PDF
        "page-pdf"
      when SubmissionAsset::Mime::PLAIN_TEXT, SubmissionAsset::Mime::HTML
        "page-doc"
      when SubmissionAsset::Mime::EMAIL, SubmissionAsset::Mime::NEWSGROUP_POST
        "email"
      else
        "page"
      end
    end
  end
end
