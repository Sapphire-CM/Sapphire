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

    params[:account].delete(:current_password)

    params[:account].delete(:password) if params[:account][:password].blank?
    params[:account].delete(:password_confirmation) if params[:account][:password_confirmation].blank?


    if @account.update_attributes(params[:account])
      redirect_to root_path, notice: "Account was successfully updated."
    else
      render :edit
    end
  end

end
