class StudentGroup < ActiveRecord::Base
  belongs_to :tutorial_group
  has_many :student_registrations, dependent: :destroy

  attr_accessible :name

end
