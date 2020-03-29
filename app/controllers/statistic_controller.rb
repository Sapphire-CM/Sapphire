class StatisticController < ApplicationController
  include TermContext

  def show
    @term = Term.find(params[:id])

    authorize @term
  end
end
