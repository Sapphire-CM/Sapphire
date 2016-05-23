# encoding: utf-8

require 'ostruct'

module Sapphire
  module AutomatedCheckers
    class CheckUniverse
      class CheckData < Struct.new(:subject, :check, :submission)
        delegate :unknown!, :failed!, :success!, :status, to: :check
        delegate :exercise, :student_group, :term_registrations, to: :submission

        def to_ascii(string)
          string.gsub(/[äöüßéá]/) do |match|
            case match
            when 'ä' then 'ae'
            when 'ö' then 'oe'
            when 'ü' then 'ue'
            when 'ß' then 'ss'
            when 'é' then 'e'
            when 'á' then 'a'
            end
          end.force_encoding('US-ASCII')
        end
      end

      def initialize(prepare_block, subject, submission)
        @data = CheckData.new
        @data.subject = subject
        @data.submission = submission
        @data.instance_eval(&prepare_block) if prepare_block.present?
      end

      def run(check, &block)
        new_data = @data.dup
        new_data.check = check
        new_data.freeze
        new_data.instance_eval(&block)
      end
    end
  end
end
