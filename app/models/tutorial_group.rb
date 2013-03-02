class TutorialGroup < ActiveRecord::Base
  belongs_to :term
  
  has_one :tutor_term_registrations
  delegate :tutor, :to => :tutor_term_registrations

  attr_accessible :title
  
  validates_presence_of :title
  validates_uniqueness_of :title

  has_many :student_term_registrations, :dependent => :destroy
  delegate :students, :through => :student_term_registrations
  
  has_one :course, :through => :term

end
