module TermContext
  extend ActiveSupport::Concern

  protected
  def current_term
    @term
  end

  private
  def fetch_term
    @term = Term.find(params[:term_id])
  end

  included do
    before_action :fetch_term
    helper_method :current_term
  end
end