module AccountContext
  extend ActiveSupport::Concern

  included do
    before_action :fetch_account
    helper_method :account
  end

  private

  def fetch_account
    @account = Account.find(params[:account_id])
  end

  def account
    @account
  end
end
