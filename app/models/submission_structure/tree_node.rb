class SubmissionStructure::TreeNode
  extend ActiveModel::Translation

  attr_reader :name, :size, :mtime, :icon
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

  def path
    @path ||= root? ? name : ::File.join(parent.path, name)
  end

  def path_without_root
    ::File.join(*parents.reject(&:root?).map(&:name))
  end

  def relative_path
    (path.presence || "").gsub(/^\/+/, "")
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
