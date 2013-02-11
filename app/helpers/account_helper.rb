module AccountHelper
  def account_title
    if current_account.accountable.present?
      current_account.fullname
    else
      current_account.email
    end
  end
end
