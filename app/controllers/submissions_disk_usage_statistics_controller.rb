class SubmissionsDiskUsageStatisticsController < ApplicationController
  include TermContext

  before_action :set_term, :set_stats, only: [:show]

  private
    def set_term
      @term = Term.find(params[:term_id])

      authorize @term
    end

   def set_stats
     @exercises_statistics = Hash.new
     @term.exercises.each do |exercise|
       @exercises_statistics[exercise] = Exercise::SubmissionsDiskUsageStatistics.new(exercise).submissions_disk_usage
     end
   end
end
