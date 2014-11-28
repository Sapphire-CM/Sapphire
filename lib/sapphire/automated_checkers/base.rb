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

      def self.asset_identifier(identifier)
        checks_asset_files!

        @asset_identifiers ||= []
        @asset_identifiers << identifier
      end

      def self.asset_identifiers(*args)
        args.each do |identifier|
          asset_identifier(identifier)
        end
      end


      def self.content_type(type)
        @content_types ||= []
        @content_types << type
      end

      def self.content_types(*args)
        args.each do |type|
          content_type(type)
        end
      end

      def self.content_type?(content_type)
        if @content_types.present?
          @content_types.include?(content_type)
        else
          true
        end
      end

      def self.asset_identifier?(identifier)
        if @asset_identifiers.present?
          @asset_identifiers.include?(identifier)
        else
          true
        end
      end

      def self.prepare(&block)
        @prepare_block = block
      end

      def self.check(identifier, title = nil, &block)
        if block_given?
          @checks ||= {}

          c = Check.new(identifier, title, block, self)
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

      def prepare_subject(subject, submission)
        @universe = CheckUniverse.new(@prepare_block, subject, submission)
      end

      def perform_check(identifier)
        check = @checks[identifier]
        check.check!(self, @universe) if check
        check
      end
    end
  end
end