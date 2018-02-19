class WelcomeNotificationPolicy < TermBasedPolicy
  def create?
    lecturer_permissions?
  end
end
