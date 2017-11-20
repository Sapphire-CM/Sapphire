class EmailAddressesController < ApplicationController
  include AccountContext
  before_action :fetch_email_address, only: [:edit, :update, :destroy]

  def index
    authorize EmailAddressPolicy.policy_record_with(account: account)
    @email_addresses = account.email_addresses
  end

  def new
    @email_address = EmailAddress.new
    authorize @email_address

    @email_address.account = account
  end

  def create
    @email_address = EmailAddress.new(email_params)
    authorize @email_address

    @email_address.account = account

    if @email_address.save
      redirect_to account_email_addresses_path(account), notice: "Added #{@email_address.email} to this account"
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @email_address.update(email_params)
      redirect_to account_email_addresses_path(account), notice: 'Successfully updated email address'
    else
      render :edit
    end
  end

  def destroy
    @email_address.destroy
    redirect_to account_email_addresses_path(account), notice: "Removed #{@email_address.email} from this account"
  end

  private

  def email_params
    params.require(:email_address).permit(:email)
  end

  def fetch_email_address
    @email_address = account.email_addresses.find(params[:id])
    authorize @email_address
  end
end
