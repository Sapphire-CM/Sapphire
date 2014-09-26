class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  def index
    authorize Account

    @accounts = Account.scoped.page(params[:page]).per(50)
    @accounts = @accounts.search(params[:q]) if params[:q].present?
  end

  def show
    @term_registrations = @account.term_registrations
  end

  def edit
  end

  def update
    updated = if account_params[:password].present?
      @account.update_with_password(account_params)
    else
      @account.update(account_params)
    end

    if updated
      sign_in @account, bypass: true if current_account == @account
      redirect_to root_path, notice: 'Account was successfully updated.'
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
      params_everybody = [
        :options
      ]

      params_admin = [
        :forename,
        :surname,
        :matriculation_number
      ]

      params_password = [
        :current_password,
        :password,
        :password_confirmation
      ]

      permitted_params = params_everybody.dup
      permitted_params << params_password.dup if params[:account] && params[:account][:password].present?
      permitted_params << params_admin.dup if current_account.admin?

      p = params.require(:account).permit(permitted_params)
    end
end
