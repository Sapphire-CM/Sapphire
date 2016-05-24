class SubmissionFolder
  include ActiveModel::Model

  attr_accessor :path, :name, :submission

  def path
    (@path || "").gsub(/^submission\/?/, "")
  end

  def full_path
    return "" if path.blank? && name.blank?

    p = File.join(path, name)
    Pathname.new(p).cleanpath.to_s.gsub(/^\/+/, "")
  end

  def path_available?
    !@submission.submission_assets.path_exists?(full_path)
  end
end
