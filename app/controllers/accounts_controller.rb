class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  def index
    authorize Account

    @accounts = Account.scoped.page(params[:page]).per(50)
    @accounts = @accounts.search(params[:q]) if params[:q].present?
  end

  def show
    @registrations = []
  end

  def edit
  end

  def update
    if @account.update_with_password(account_params)
      redirect_to root_path, notice: "Account was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @account.destroy
    redirect_to accounts_path
  end

  private
    def set_account
      @account = Account.find(params[:id])
      authorize @account
    end

    def account_params
      params.require(:account).permit(
        :forename,
        :surname,
        :matriculation_number,
        :options)
    end
end
