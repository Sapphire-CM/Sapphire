class SubmissionsDiskUsageStatisticsController < ApplicationController
  include TermContext

  before_action :set_term, :set_stats, only: [:show]

  private
    def set_term
      @term = Term.find(params[:term_id])

      authorize @term
    end

   def set_stats
     @submission_disk_usages = Hash.new
     @term.exercises.each do |exercise|
       @submission_disk_usages[exercise] = Exercise::SubmissionsDiskUsageStatistics.new(exercise).submissions_disk_usage
     end
   end
end
