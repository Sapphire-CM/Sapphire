class TutorialGroup < ActiveRecord::Base
  belongs_to :term

  has_one :course, :through => :term
  
  attr_accessible :title, :description
  
  validates_presence_of :title
  validates_uniqueness_of :title

  has_one :tutor_registration
  delegate :tutor, :to => :tutor_registration, :allow_nil => true

  has_many :student_registrations, :dependent => :destroy
  
  def students
    tmp = []
    student_registrations.each do |registration|
      tmp << registration.student
    end
    tmp
  end
end
