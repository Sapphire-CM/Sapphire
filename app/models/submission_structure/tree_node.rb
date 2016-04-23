class SubmissionStructure::TreeNode
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
