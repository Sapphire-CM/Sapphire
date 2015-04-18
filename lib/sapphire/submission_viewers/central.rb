require 'singleton'

module Sapphire
  module SubmissionViewers
    class Central
      include Singleton

      class << self
        delegate :register, :registered_viewers, :viewer_for_submission, to: :instance
      end

      def initialize
        @registered_viewers = {}
      end

      def register(*args)
        args.each do |viewer|
          if viewer.ancestors.include? Base
            @registered_viewers[viewer.identifier] = viewer
          end
        end
      end

      def registered_viewers
        @registered_viewers.values
      end

      def viewer_for_submission(submission, params)
        ex = submission.exercise

        viewer = nil
        if ex.submission_viewer?
          viewer_class = viewer_for_identifier(ex.submission_viewer_identifier)
          viewer = viewer_class.new(submission, params)
        end
        viewer
      end

      def viewer_for_identifier(identifier)
        @registered_viewers[identifier]
      end
    end
  end
end

load File.join(File.dirname(__FILE__), 'register_viewers.rb')
