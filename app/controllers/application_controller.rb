class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_account!

  include Pundit
  after_action :verify_authorized, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def pundit_user
    current_account
  end

  def user_not_authorized(e)
    Rails.logger.info(e.message)
    destination = if account_signed_in?
      root_path
    else
      new_user_account_path
    end
    flash[:alert] = 'You are not authorized to perform this action.'

    respond_to do |format|
      format.json { render nothing: true, status: :unauthorized }
      format.js { js_redirect_to destination, alert: alert }
      format.html { redirect_to destination, alert: alert }
    end
  end

  def record_not_found
    render "record_not_found"
  end

  def js_redirect_to(path, flashes = {})
    flashes.each { |key, value| flash[key] = value }
    render js: "window.location = '#{path}';", status: :unauthorized
  end
  helper_method :js_redirect_to
end
