module SubmissionAssetsHelper
  def inline_submission_asset(submission_asset)
    case submission_asset.content_type
    when SubmissionAsset::Mime::NEWSGROUP_POST then
      inline_newsgroup_post_asset(submission_asset)
    else
      content_tag :div, class: "panel" do
        content = "<h5>Cannot display inline version of this asset</h5>".html_safe
        content << link_to("View raw", submission_asset_path(submission_asset))
      end
    end
  end

  private
  def inline_newsgroup_post_asset(submission_asset)
    render "code_panel", code: inline_code(submission_asset.file.read, :email), raw_url: submission_asset_path(submission_asset)
  end

  def inline_code(code, lang)
    coderay(code.force_encoding("UTF-8"), lang)
  end
end
