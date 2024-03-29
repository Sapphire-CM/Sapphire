# create_table :email_addresses, force: :cascade do |t|
#   t.string   :email
#   t.integer  :account_id
#   t.datetime :created_at, null: false
#   t.datetime :updated_at, null: false
#   t.index [:account_id], name: :index_email_addresses_on_account_id
#   t.index [:email], name: :index_email_addresses_on_email, unique: true
# end

class EmailAddress < ActiveRecord::Base
  belongs_to :account

  validates :account, presence: true
  validates :email, presence: true, uniqueness: true, email: true
  validate :validate_no_account_with_same_email_exists

  private

  def validate_no_account_with_same_email_exists
    if Account.where(email: email).exists?
      errors.add(:email, 'has already been taken')
    end
  end
end
