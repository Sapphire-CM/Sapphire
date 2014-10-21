class EmailAddress < ActiveRecord::Base
  belongs_to :account

  validates_presence_of :email
  validates_uniqueness_of :email
  validate :validate_no_account_with_same_email_exists


  private
  def validate_no_account_with_same_email_exists
    if Account.where(email: self.email).exists?
      errors.add(:email, "has already been taken")
    end
  end
end
