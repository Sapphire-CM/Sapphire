class ImpersonationsController < ApplicationController
  before_action :set_account, only: :create
  before_action :set_impersonation

  def create
    if @impersonation.impersonate!
      redirect_to root_path, notice: "You are now using Sapphire as '#{@account.email}'."
    else
      redirect_to root_path, alert: "Failed to impersonate '#{@account}'."
    end
  end

  def destroy
    old_account = current_account

    if @impersonation.destroy
      redirect_back fallback_location: root_path, notice: "No longer impersonating '#{old_account.email}'."
    else
      redirect_back fallback_location: root_path
    end
  end

  private
  def set_impersonation
    @impersonation = Impersonation.new(warden: warden, session: session, current_account: current_account, impersonatable: @account)

    authorize @impersonation
  end

  def set_account
    @account = Account.find(params[:account_id])
  end
end
