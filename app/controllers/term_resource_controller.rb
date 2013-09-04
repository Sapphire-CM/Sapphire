class TermResourceController < ApplicationController

  private
    def current_term
      id = params.deep_find(:term_id)
      @current_term ||= Term.find(id) if id
      @current_term ||= @term
    end
    helper_method :current_term
end
