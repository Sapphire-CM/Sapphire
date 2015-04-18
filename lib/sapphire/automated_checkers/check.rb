module Sapphire
  module AutomatedCheckers
    class Check
      attr_reader :checker_class

      [:unknown, :failed, :success].each do |method|
        define_method "#{method}?".to_sym do
          @status == method
        end

        define_method "#{method}!".to_sym do
          @status = method
        end
      end

      def initialize(identifier, title, check, checker_class)
        @identifier = identifier
        @title = title
        @check = check
        @checker_class = checker_class
      end

      def title
        @title.presence || @identifier.to_s.titleize
      end

      def identifier
        "#{@checker_class.to_s.demodulize}::#{@identifier}"
      end

      attr_reader :status

      def check!(_checker, universe)
        unknown!

        begin
          # runs block in the universe's context - keeping all internals clean!
          universe.run self, &@check
        rescue StandardError => e
          Rails.logger.info e.to_s
          Rails.logger.info e.backtrace.join("\n")
          failed!
        end
      end
    end
  end
end
