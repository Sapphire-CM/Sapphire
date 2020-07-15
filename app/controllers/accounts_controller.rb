class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  def index
    authorize Account

    @accounts = Account.default_order.page(params[:page])
    @accounts = @accounts.search(params[:q]) if params[:q].present?
  end

  def show
    @term_registrations = @account.term_registrations
  end

  def new
    @account = Account.new
    authorize @account
  end

  def create
    @account = Account.new(new_account_params)
    authorize @account

    if @account.save
      redirect_to account_path(@account), notice: "Account was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    updated = if edit_account_params[:password].present?
      @account.update_with_password(edit_account_params)
    else
      @account.update(edit_account_params)
    end

    if updated
      bypass_sign_in @account if current_account == @account
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

  def new_account_params
    params.require(:account).permit(:email, :forename, :surname, :matriculation_number, :password)
  end

  def edit_account_params
    permitted_params = [
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

    params_preferences = [
      :comment_markdown_preference
    ]

    permitted_params << params_password.dup if params[:account] && params[:account][:password].present?
    permitted_params << params_admin.dup if current_account.admin?
    permitted_params << params_preferences if current_account.staff_of_any_term? || current_account.admin?

    params.require(:account).permit(permitted_params)
  end
end
