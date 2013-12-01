module Sapphire
  module AutomatedCheckers
    class Base
      attr_reader :subject

      class << self
        [:submissions, :assets, :asset_files].each do |method|
          define_method "checks_#{method}?".to_sym do
            @checker_configuration == method
          end

          define_method "checks_#{method}!".to_sym do
            @checker_configuration = method
          end
        end
      end

      def self.create
        self.new(@checks, @prepare_block)
      end

      def self.content_types(*args)
        args.each do |content_type|
          content_type(content_type)
        end
      end

      def self.content_type(content_type)
        (@content_types||=[]) << content_type
      end

      def self.content_type?(content_type)
        if @content_types.present?
          @content_types.include?(content_type)
        else
          true
        end
      end

      def self.prepare(&block)
        @prepare_block = block
      end

      def self.check(identifier, &block)
        if block_given?
          @checks ||= {}

          c = Check.new(identifier, block, self)
          @checks[c.identifier] = c
        end
      end

      def self.check_identifiers
        @checks.keys
      end

      def self.checks
        @checks.values
      end

      def self.title
        @title ||= self.to_s.demodulize.titleize
      end

      def initialize(checks, prepare_block)
        @checks = checks
        @prepare_block = prepare_block
      end

      def prepare_subject(subject, student_group, exercise)
        @universe = CheckUniverse.new(@prepare_block, subject, student_group, exercise)
      end

      def perform_check(identifier)
        check = @checks[identifier]
        check.check!(self, @universe) if check
        check
      end
    end
  end
end