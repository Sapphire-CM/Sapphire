module SubmissionAssetsHelper
  def inline_submission_asset(submission_asset)
    case submission_asset.content_type
    when SubmissionAsset::Mime::NEWSGROUP_POST then
      inline_newsgroup_post_asset(submission_asset)
    when SubmissionAsset::Mime::EMAIL then
      inline_email_asset(submission_asset)
    when SubmissionAsset::Mime::STYLESHEET then
      inline_css_asset(submission_asset)
    when SubmissionAsset::Mime::HTML then
      inline_html_asset(submission_asset)
    when SubmissionAsset::Mime::JPEG || SubmissionAsset::Mime::PNG then
      inline_image_asset(submission_asset)
    else
      content_tag :div, class: "panel" do
        content = "<strong>Cannot display inline version of this asset</strong> ".html_safe
        content << link_to("View raw", submission_asset_path(submission_asset), class: "tiny button", target: "_blank")
      end
    end
  end

  def submission_asset_file_label(exercise)
     title = "#{exercise.title} .zip file"
     title << " (max. #{number_to_human_size exercise.maximum_upload_size})" if exercise.maximum_upload_size.present?
     title
  end

  private
  def inline_newsgroup_post_asset(submission_asset)
    render "submission_assets/code_panel", code: auto_link(inline_code(submission_asset.file.read, :email), sanitize: false, html: {target: "_blank"}).html_safe, raw_url: submission_asset_path(submission_asset)
  end

  def inline_email_asset(submission_asset)
    render "submission_assets/code_panel", code: auto_link(inline_code(submission_asset.file.read, :email), sanitize: false, html: {target: "_blank"}).html_safe, raw_url: submission_asset_path(submission_asset)
  end

  def inline_css_asset(submission_asset)
    render "submission_assets/code_panel", code: inline_code(submission_asset.file.read, :css), raw_url: submission_asset_path(submission_asset)
  end

  def inline_html_asset(submission_asset)
    render "submission_assets/code_panel", code: auto_link(inline_code(submission_asset.file.read, :html), sanitize: false, html: {target: "_blank"}).html_safe, raw_url: submission_asset_path(submission_asset)
  end

  def inline_image_asset(submission_asset)
    render "submission_assets/image_panel", image_path: submission_asset_path(submission_asset)
  end

  def inline_code(code, lang)
    coderay(code.force_encoding("UTF-8"), lang)
  end

end
