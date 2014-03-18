class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_account!

  include Pundit
  after_action :verify_authorized, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private
    def pundit_user
      current_account
    end

    def user_not_authorized
      destination = request.referer || new_account_session_path
      alert = 'You are not authorized to perform this action.'

      if request.xhr?
        js_redirect_to destination, alert: alert
      else
        redirect_to destination, alert: alert
      end
    end

    def js_redirect_to(path, flashes={})
      flashes.each { |key, value| flash[key] = value }
      render js: "window.location = '#{path}';"
    end
    helper_method :js_redirect_to
end
