
  module Scanners
    class Email < ::CodeRay::Scanners::Scanner
      register_for :email

      protected
      def setup
        @state = :headers
      end

      def scan_tokens encoder, options
        state = options[:state] || @state

        header_state = :begin

        until eos?
          case state
          when :headers
            case header_state
            when :begin
              if match = scan(/^[A-Z][\w-]+:/)
                encoder.text_token match, :attribute_name
                header_state = :contents
              elsif match = scan(/\n/)
                encoder.text_token match, :space
                state = :body
              elsif match = scan(/\s+/)
                encoder.text_token match, :space
                header_state = :contents
              else
                puts "fuu 1"
                state = :body
                # raise_inspect "else case \" reached; %p not handled." % peek(1), encoder
              end
            when :contents
              if match = scan(/^\s+/)
                encoder.text_token match, :space
              elsif match = scan(/.*\n/)
                encoder.text_token match, :attribute_value
                header_state = :begin
              end
            end
          when :body
            if match = scan(/-- /)
              encoder.text_token match, :comment
              state = :sig
            elsif match = scan(/^>.*\n/)
              encoder.text_token match, :docstring
            else
              match = scan(/.*\n/)
              encoder.text_token match, :plain
            end
          when :sig
            match = scan(/.*/m)
            encoder.text_token match, :comment
          else
            puts "fuu 3 - headers done?!"
            # raise_inspect "else case \" reached; %p not handled." % peek(1), encoder
            return
          end
        end
        encoder
      end
    end
  end
