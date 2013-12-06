module Sapphire
  module SubmissionViewers
    class Ex5StylesheetViewer < Base
      def setup
        @assets = submission.submission_assets.where(content_type: SubmissionAsset::Mime::STYLESHEET).order(:file)
      end

      def assets
        @assets
      end

      def view_options

      end
    end
  end
end