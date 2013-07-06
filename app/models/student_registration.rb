class StudentRegistration < ActiveRecord::Base
  belongs_to :student, class_name: "Account", foreign_key: :account_id
  belongs_to :student_group

  has_one :tutorial_group, through: :student_group
  has_one :term, through: :student_group

  has_many :submissions
  attr_accessible :registered_at, :comment
end