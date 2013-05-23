class AccountsController < ApplicationController

  def index
    @accounts = Account.scoped.page(params[:page]).per(50)
    @accounts = @accounts.search(params[:q]) if params[:q].present?
  end

  def show
    @account = Account.find(params[:id])

    @registrations = []
  end

  def edit
    @account = Account.find(params[:id])
  end

  def update
    @account = Account.find(params[:id])

    if @account.update_with_password(params[:account])
      redirect_to root_path, notice: "Account was successfully updated."
    else
      render :edit
    end
  end
end
