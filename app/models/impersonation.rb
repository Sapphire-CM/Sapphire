class Impersonation
  include ActiveModel::Model
  include Devise::Controllers::SignInOut

  attr_accessor :warden, :session, :current_account, :impersonatable

  def active?
    self.session.present? && self.session["impersonator_id"].present?
  end

  def impersonate!
    session["impersonator_id"] = current_account.id unless active?
    sign_in(:account, impersonatable)
  end

  def destroy
    return false unless active?

    sign_in(:account, Account.find(session["impersonator_id"]))
    session["impersonator_id"] = nil
  end
end
