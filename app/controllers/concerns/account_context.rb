module AccountContext
  extend ActiveSupport::Concern

  included do
    before_action :fetch_account

    def fetch_account
      @account = Account.find(params[:account_id])
    end

    def account
      @account
    end
    helper_method :account
  end
end