json.more @accounts.count > 5
json.subjects @accounts do |account|
  json.id account.id
  json.html term_account_card(account)
end