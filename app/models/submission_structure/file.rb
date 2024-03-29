class SubmissionStructure::File < SubmissionStructure::TreeNode
  attr_reader :icon, :size, :name, :mtime, :submission_asset, :submitter

  def initialize(submission_asset, parent = nil)
    @icon = icon_for_submission_asset(submission_asset)
    @size = submission_asset.filesystem_size
    @name = submission_asset.filename
    @mtime = submission_asset.updated_at
    @submission_asset = submission_asset
    @submitter = submission_asset.submitter
  end

  def file?
    true
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
    when *SubmissionAsset::Mime::ARCHIVES
      "page-multiple"
    else
      "page"
    end
  end
end
