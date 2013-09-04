class StudentGroup < ActiveRecord::Base
  belongs_to :tutorial_group

  has_one :term, through: :tutorial_group
  has_many :student_registrations, dependent: :destroy
  has_many :students, through: :student_registrations

  attr_accessible :title, :solitary

end
