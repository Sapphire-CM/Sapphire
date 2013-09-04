class StudentRegistration < ActiveRecord::Base
  belongs_to :student, class_name: "Account", foreign_key: :account_id
  belongs_to :student_group

  has_one :tutorial_group, through: :student_group

  attr_accessible :registered_at, :comment

end
