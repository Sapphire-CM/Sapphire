class SubmissionStructure::Directory < SubmissionStructure::TreeNode
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

  def resolve(path, create_directories: true)
    parts = Pathname(path).each_filename.to_a

    node = self
    parts.each do |name|
      old_node = node
      node = node[name]

      unless node
        if create_directories
          node = SubmissionStructure::Directory.new(name, old_node)
          old_node << node
        else
          raise FileDoesNotExist.new("#{name}, #{path}, #{@nodes.keys}")
        end
      end
    end

    node
  end

  def entries
    @nodes.values
  end

  def submission_assets
    entries.map do |e|
      assets = if e.is_a? File
        e.submission_asset
      else
        e.submission_assets
      end
    end.flatten
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