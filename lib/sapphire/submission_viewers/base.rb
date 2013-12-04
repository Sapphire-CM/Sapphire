module Sapphire
  module SubmissionViewers
    class Base
      def self.identifier
        self.to_s.demodulize
      end

      def self.title
        self.to_s.demodulize.titleize
      end

      attr_reader :submission

      def initialize(submission)
        @submission = submission
        setup
      end

      def setup; end

      def toolbar?
        !!@toolbar
      end

      def toolbar
        @toolbar
      end

      def view
        self.class.to_s.demodulize.underscore
      end

      def view_options
        {}
      end
    end
  end
end