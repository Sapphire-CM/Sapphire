class TermResourceController < ApplicationController

  private
    def current_term
      id = params[:term_id] || params[:id]
      @current_term ||= Term.find(id) if id
    end
    helper_method :current_term
end
