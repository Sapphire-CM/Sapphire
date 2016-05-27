class SubmissionFolder
  include ActiveModel::Model

  attr_accessor :path, :name, :submission

  def path
    (@path || "").gsub(/^submission\/?/, "")
  end

  def full_path
    return path if name.blank?

    p = File.join(path, name)
    SubmissionAsset.normalize_path(p)
  end

  def path_available?
    !@submission.submission_assets.path_exists?(full_path)
  end
end
