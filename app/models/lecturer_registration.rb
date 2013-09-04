class LecturerRegistration < ActiveRecord::Base
  belongs_to :lecturer, class_name: "Account", foreign_key: "account_id"
  belongs_to :term

  has_one :course, through: :term

  attr_accessible :term, :lecturer, :registered_at

end
