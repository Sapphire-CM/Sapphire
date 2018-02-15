class WelcomeNotificationsController < ApplicationController
  include TermContext

  def create
    authorize WelcomeNotificationPolicy.term_policy_record(@term)

    NotificationJob.welcome_notifications_for_term(@term)

    redirect_to term_path(@term), notice: 'Welcome notifications successfully queued for sending'
  end
end
