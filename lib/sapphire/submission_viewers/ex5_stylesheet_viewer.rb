module Sapphire
  module SubmissionViewers
    class Ex5StylesheetViewer < Base
      def setup
        @assets = submission.submission_assets.where(content_type: SubmissionAsset::Mime::STYLESHEET).order(:file)
      end

      attr_reader :assets

      def view_options
      end

      def asset_options
        assets.map do |asset|
          [File.basename(asset.file.to_s), Rails.application.routes.url_helpers.submission_asset_path(asset)]
        end
      end
    end
  end
end
