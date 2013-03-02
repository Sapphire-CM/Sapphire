class Term < ActiveRecord::Base
  belongs_to :course
  
  has_many :exercises, :dependent => :destroy
  has_many :tutorial_groups, :dependent => :destroy

  has_many :course_leader_term_registrations, :dependent => :destroy
  has_many :tutor_term_registrations, :dependent => :destroy
  has_many :student_term_registrations, :dependent => :destroy

  delegate :lecturer, :to => :lecturer_term_registrations
  delegate :tutors, :to => :tutor_term_registrations
  delegate :students, :to => :student_term_registrations
  
  attr_accessible :title, :description, :course, :course_id, :exercises
  
  validates_presence_of :title, :course_id
  validates_uniqueness_of :title
  
  scope :with_courses, joins(:course).includes(:course)

  has_many :student_imports, :dependent => :destroy, :class_name => "Import::StudentImport"

end
