class SubmissionsDiskUsageStatisticsController < ApplicationController
  include TermContext

  before_action :set_term, only: [:show]

  private
    def set_term
      @term = Term.find(params[:term_id])

      authorize @term
    end
end
