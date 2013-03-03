class AccountsController < ApplicationController

  def index
    @accounts = Account.scoped.page(params[:page]).per(50)
    @accounts = @accounts.search(params[:q]) if params[:q].present?
  end

  def show
    @account = Account.find(params[:id])
  end

end
