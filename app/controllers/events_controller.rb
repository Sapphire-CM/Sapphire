class EventsController < ApplicationController
  include TermContext

  skip_after_action :verify_authorized, only: [:index]

  def index
    set_events

    respond_to :json
  end

  private
  def staff_account?
    @staff_account = current_account.staff_of_term?(@term) if @staff_account.nil?

    @staff_account
  end
  helper_method :staff_account?

  def set_events
    @events = policy_scope(Event).for_term(current_term).includes(:account).time_ordered.page(params[:page])

    if params[:scopes].present?
      @events = @events.filter_by_scopes(params[:scopes])
    end
  end

end
