module SubmissionAssetsHelper
  def inline_submission_asset(submission_asset)
    unless File.exist?(submission_asset.file.to_s)
      content_tag :div, class: 'panel' do
        '<strong>Cannot display this asset, as the associated file seems to be missing</strong> '.html_safe
      end
    else
      case submission_asset.content_type
      when SubmissionAsset::Mime::PDF
        inline_pdf_asset(submission_asset)
      when SubmissionAsset::Mime::NEWSGROUP_POST
        inline_newsgroup_post_asset(submission_asset)
      when SubmissionAsset::Mime::EMAIL
        inline_email_asset(submission_asset)
      when SubmissionAsset::Mime::STYLESHEET
        inline_css_asset(submission_asset)
      when SubmissionAsset::Mime::HTML
        inline_html_asset(submission_asset)
      when SubmissionAsset::Mime::JPEG, SubmissionAsset::Mime::PNG
        inline_image_asset(submission_asset)
      when SubmissionAsset::Mime::PLAIN_TEXT
        inline_plain_text_asset(submission_asset)
      else
        content_tag :div, class: 'panel' do
          content = '<strong>Cannot display inline version of this asset</strong> '.html_safe
          content << link_to('View raw', submission_asset_path(submission_asset), class: 'tiny button', target: '_blank')
        end
      end
    end
  end

  def submission_asset_file_change(path, file)
    File.join(*([path, file].map(&:presence).compact))
  end

  def submission_asset_extraction_status(submission_asset)
    case submission_asset.extraction_status.to_s
    when "extraction_pending" then "Pending"
    when "extraction_in_progress" then "In Progress"
    when "extraction_done" then "Done"
    when "extraction_failed" then "Failed"
    else "Unknown (#{submission_asset.extraction_status.inspect})"
    end
  end

  private

  def inline_pdf_asset(submission_asset)
    render 'submission_assets/pdf_panel', raw_url: submission_asset_path(submission_asset)
  end

  def inline_newsgroup_post_asset(submission_asset)
    render 'submission_assets/code_panel', code: auto_link(inline_code(submission_asset.utf8_contents, :email), sanitize: false, html: { target: '_blank' }).html_safe, raw_url: submission_asset_path(submission_asset)
  end

  def inline_email_asset(submission_asset)
    render 'submission_assets/code_panel', code: auto_link(inline_code(submission_asset.utf8_contents, :email), sanitize: false, html: { target: '_blank' }).html_safe, raw_url: submission_asset_path(submission_asset)
  end

  def inline_css_asset(submission_asset)
    render 'submission_assets/code_panel', code: inline_code(submission_asset.utf8_contents, :css), raw_url: submission_asset_path(submission_asset)
  end

  def inline_html_asset(submission_asset)
    render 'submission_assets/code_panel', code: auto_link(inline_code(submission_asset.utf8_contents, :html), sanitize: false, html: { target: '_blank' }).html_safe, raw_url: submission_asset_path(submission_asset)
  end

  def inline_image_asset(submission_asset)
    render 'submission_assets/image_panel', image_path: submission_asset_path(submission_asset)
  end

  def inline_plain_text_asset(submission_asset)
    render 'submission_assets/code_panel', code: auto_link(simple_format(h(submission_asset.utf8_contents)), sanitize: false, html: { target: '_blank' }).html_safe, raw_url: submission_asset_path(submission_asset)
  end

  def inline_code(code, lang)
    coderay(code, lang)
  end
end
