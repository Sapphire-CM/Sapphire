class EventsController < ApplicationController
  include TermContext

  skip_after_action :verify_authorized, only: :index

  respond_to :json

  def index
    @events = policy_scope(Event).for_term(current_term).includes(:account).time_ordered.page(params[:page])
  end

  private
  def staff_account?
    @staff_account = current_account.staff_of_term?(@term) if @staff_account.nil?

    @staff_account
  end
  helper_method :staff_account?
end
