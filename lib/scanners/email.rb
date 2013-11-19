module CodeRay
  module Scanners
    class Email < Scanner
      register_for :email



      protected
      def setup
        @state = :initial
      end

      def scan_tokens encoder, options
        state = options[:state] || @state

        if [:string, :key].include? state
          encoder.begin_group state
        end

        until eos?
          case state

          when :initial
            if match = scan(/ \s+ /x)
              encoder.text_token match, :space
            end
          when :string, :key
            raise_inspect "else case \" reached; %p not handled." % peek(1), encoder
          end
        end

        if options[:keep_state]
          @state = state
        end

        if [:string, :key].include? state
          encoder.end_group state
        end

        encoder
      end
    end
  end
end