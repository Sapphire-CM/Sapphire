module Terms::AccountsHelper
  def term_account_card(account)
    [].tap do |parts|
      parts << content_tag(:strong, account.fullname) + tag(:br)
      parts << h(account.matriculation_number) + tag(:br) if account.matriculation_number.present?
      parts << h(account.email)
    end.inject(&:+)
  end
end
