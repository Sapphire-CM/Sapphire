module Sapphire
  module SubmissionViewers
    class Ex4HTMLViewer < Base
      include Rails.application.routes.url_helpers

      attr_reader :assets
      def setup
        if asset.present?
          @contents = asset.file.read.force_encoding("UTF-8")
          @doc = Nokogiri::HTML(@contents)
          @displayable = true
        end
      end


      def stylesheets
        @doc.css('link[rel=stylesheet]').each do |stylesheet|
          unless stylesheet['href'] =~ /^http:\/\//
            asset = stylesheet_asset(File.basename(stylesheet['href'] || ""))
            stylesheet["href"] =  submission_asset_path(asset) if asset.present?
          end
        end
      end

      def headers
        head_elements = @doc.css("head").dup
        head_elements.css("link[rel=stylesheet]").each do |stylesheet|
          unless stylesheet['href'] =~ /^http:\/\//
            asset = stylesheet_asset(File.basename(stylesheet['href'] || ""))
            stylesheet['href'] =  submission_asset_path(asset) if asset.present?
          end
        end
        head_elements.search("title").remove
        head_elements.children().to_s.html_safe
      end

      def body
        body = @doc.css("body").dup
        body.css('img').each do |img|
          unless img['src'] =~ /^http:\/\//
            asset = image_asset(File.basename(img['src'] || ""))
            img['src'] =  submission_asset_path(asset) if asset.present?
          end
        end

        body.css('a').each do |link|
          link['href'] =  submission_html_path(File.basename link['href'] || "") unless link['href'] =~ /^http:\/\//
        end

        body.children().to_s.html_safe
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
        submission.submission_assets.stylesheets.where(file: identifier).first
      end

      def image_asset(identifier)
        submission.submission_assets.images.where(file: identifier).first
      end

      def displayable?
        !!@displayable
      end

      def view_options

      end
    end
  end
end