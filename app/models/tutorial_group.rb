class TutorialGroup < ActiveRecord::Base
  belongs_to :term

  has_one :course, :through => :term
  
  attr_accessible :title
  
  validates_presence_of :title
  validates_uniqueness_of :title

  has_one :tutor_term_registration
  delegate :tutor, :to => :tutor_term_registration, :allow_nil => true

  has_many :student_term_registrations, :dependent => :destroy
  # delegate :students, :to => :student_term_registrations, :allow_nil => true
  
  def students
    tmp = []
    student_term_registrations.each do |registration|
      tmp << registration.student
    end
    tmp
  end
end
