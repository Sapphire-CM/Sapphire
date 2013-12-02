#encoding: utf-8

require "ostruct"

module Sapphire
  module AutomatedCheckers
    class CheckUniverse
      class CheckData < Struct.new(:subject, :check, :student_group, :exercise)
        delegate :unknown!, :failed!, :success!, :status, to: :check

        def to_ascii(string)
          string.gsub(/[äöüßéá]/) do |match|
            case match
              when "ä" then 'ae'
              when "ö" then 'oe'
              when "ü" then 'ue'
              when "ß" then 'ss'
              when "é" then 'e'
              when "á" then 'a'
            end
          end.force_encoding("US-ASCII")
        end
      end

      def initialize(prepare_block, subject, student_group, exercise)
        @data = CheckData.new
        @data.subject = subject
        @data.student_group = student_group
        @data.exercise = exercise
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