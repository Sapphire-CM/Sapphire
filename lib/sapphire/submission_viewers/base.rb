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
      attr_accessor :params

      def initialize(submission, params)
        @submission = submission
        @params = params
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