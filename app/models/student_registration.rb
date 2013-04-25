class StudentRegistration < ActiveRecord::Base
  belongs_to :student, class_name: "Account", foreign_key: "account_id"
  belongs_to :tutorial_group

  has_one :term, through: :tutorial_group
  has_one :course, through: :term

  attr_accessible :registered_at

end