class WelcomeNotificationsController < ApplicationController
  include TermContext

  def create
    authorize WelcomeNotificationPolicy.term_policy_record(@term)

    Notification::SendPendingWelcomesJob.perform_later(@term)

    redirect_to term_path(@term), notice: 'Welcome notifications successfully queued for sending'
  end
end
