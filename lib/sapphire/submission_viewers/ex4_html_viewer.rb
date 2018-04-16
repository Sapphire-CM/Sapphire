module Sapphire
  module SubmissionViewers
    class Ex4HTMLViewer < Base
      include Rails.application.routes.url_helpers

      EXTERNAL_LINK = %r{^\s*(https?://|mailto:|#|tel:)}

      attr_reader :assets
      def setup
        return if asset.blank?

        @contents = asset.utf8_contents
        @doc = Nokogiri::HTML(@contents)
        @displayable = true
      end

      def stylesheets
        @doc.css('link[rel=stylesheet]').each do |stylesheet|
          unless stylesheet['href'] =~ EXTERNAL_LINK
            asset = stylesheet_asset(File.basename(stylesheet['href'] || ''))
            stylesheet['href'] =  submission_asset_path(asset) if asset.present?
          end
        end
      end

      def headers
        head_elements = @doc.css('head').dup
        head_elements.css('link[rel=stylesheet]').each do |stylesheet|
          unless stylesheet['href'] =~ EXTERNAL_LINK
            asset = stylesheet_asset(File.basename(stylesheet['href'] || ''))
            stylesheet['href'] =  submission_asset_path(asset) if asset.present?
          end
        end
        head_elements.search('title').remove
        head_elements.children.to_s.html_safe
      end

      def body
        body = @doc.css('body').dup

        body.css('img').each do |img|
          unless img['src'] =~ EXTERNAL_LINK
            asset = image_asset(File.basename(img['src'] || ''))
            img['src'] =  submission_asset_path(asset) if asset.present?
          end
        end

        body.css('video source').each do |source|
          unless source['src'] =~ EXTERNAL_LINK
            asset = generic_asset(File.basename(source['src'] || ''))
            source['src'] =  submission_asset_path(asset) if asset.present?
          end
        end

        body.css('a[href]').each do |link|
          asset = generic_asset(File.basename(link['href'] || ''))

          if asset.present? && asset.content_type != SubmissionAsset::Mime::HTML
            link['href'] = submission_asset_path(asset)
          elsif asset.present? || link['href'] !~ EXTERNAL_LINK
            link['href'] = submission_html_path(File.basename link['href'] || '')
          end
        end

        body.css("script").each(&:remove)

        body.children.to_s.html_safe
      end

      def asset
        @asset ||= begin
          scope = htmls
          scope = scope.where(file: @params[:view]) if @params[:view].present?
          scope.first
        end
      end

      def submission_html_path(filename)
        submission_viewer_path(@submission, view: filename)
      end

      def htmls
        @htmls ||= submission.submission_assets.htmls.order(:file)
      end

      def filename
        File.basename @asset.file.to_s
      end

      def stylesheet_asset(identifier)
        submission.submission_assets.stylesheets.where { lower(file) == my { identifier.downcase } }.first
      end

      def image_asset(identifier)
        submission.submission_assets.images.where { lower(file) == my { identifier.downcase } }.first
      end

      def generic_asset(identifier)
        submission.submission_assets.where { lower(file) == my { identifier.downcase } }.first
      end

      def displayable?
        !!@displayable
      end

      def view_options
      end
    end
  end
end
