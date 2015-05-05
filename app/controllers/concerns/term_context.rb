module TermContext
  extend ActiveSupport::Concern

  included do
    before_action :fetch_term
    helper_method :current_term
  end

  def current_term
    @term
  end

  private

  def fetch_term
    id = params[:term_id]
    @term = Term.find_by_id(id) if id
  end
end
