require "singleton"
require "set"

module Sapphire
  module AutomatedCheckers
    class Central
      include Singleton

      class << self
        delegate :register, :registered_checkers, :check_for_identifier, to: :instance
      end

      def initialize
        @registered_checkers = {}
        @registered_checks = {}
      end

      def register(*args)
        args.each do |checker|
          if checker.ancestors.include? Base
            @registered_checkers[checker.title.to_sym] = checker
            checker.checks.each do |check|
              @registered_checks[check.identifier] = check
            end
          end
        end
      end

      def check_for_identifier(identifier)
        @registered_checks[identifier]
      end

      def check_submissions(submissions)
        submissions.each.with_index do |s, i|
          print "."
          check_submission(s)
        end
        puts " done"

      end

      def check_submission(submission)
        assets_checkers_to_run = Hash.new {|h,k| h[k] = Array.new }
        submission_checkers_to_run = Hash.new {|h,k| h[k] = Array.new }

        submission.exercise.ratings.automated_ratings.each do |rating|
          if check = check_for_identifier(rating.automated_checker_identifier)
            if check.checker_class.checks_assets? || check.checker_class.checks_asset_files?
              assets_checkers_to_run[check.checker_class] << rating
            else
              submission_checkers_to_run[check.checker_class] << rating
            end
          else
            Rails.logger.error "Automated Checker '#{rating.automated_checker_identifier}' is unknown"
          end
        end

        submission_checkers_to_run.each do |checker, ratings|
          run_checker_with_subject_submission_and_ratings(checker, submission, submission, ratings)
        end

        submission.submission_assets.each do |asset|
          assets_checkers_to_run.each do |checker, ratings|
            if checker.asset_identifier? asset.asset_identifier
              if checker.checks_asset_files?() && checker.content_type?(asset.content_type)
                run_checker_with_subject_submission_and_ratings(checker, File.open(asset.file.path), submission, ratings)
              elsif checker.checks_assets?
                run_checker_with_subject_submission_and_ratings(checker, asset, submission, ratings)
              end
            end
          end
        end
      end

      def run_checker_with_subject_submission_and_ratings(checker, subject, submission, ratings)
        c = checker.create
        c.prepare_subject(subject, submission.student_group, submission.exercise)

        ratings.each do |rating|
          check = c.perform_check(rating.automated_checker_identifier)
          #Rails.logger.info "Checking: #{check.title} - #{rating.title} ... #{check.status}"

          evaluation = submission.submission_evaluation.evaluation_for_rating(rating)
          evaluation.checked_automatically = true


          if evaluation.is_a? BinaryEvaluation
            evaluation.value = if check.failed?
              1
            elsif check.success?
              0
            else
              evaluation.value
            end
          end
          evaluation.save!
        end
      end


      def check_identifiers_for_content_type(content_type)
        checkers_for_content_type(content_type).inject({}) do |checks, checker|
          checks[checker.class.to_s.titleize] = checker.check_identifiers
        end
      end

      def registered_checkers
        @registered_checkers.values.dup
      end

      private
      def checkers_for_content_type(content_type)
        @registered_checkers.dup.keep_if {|checker| checker.can_check? content_type }
      end
    end
  end
end


load File.join(File.dirname(__FILE__), "register_checkers.rb")
