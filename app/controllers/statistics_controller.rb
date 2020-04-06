class StatisticsController < ApplicationController
  include TermContext

  before_action :set_term, only: [:show]

  def show
        
  end

  private
    def set_term
      @term = Term.find(params[:term_id])

      authorize @term
    end
end
