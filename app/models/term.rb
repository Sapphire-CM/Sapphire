class Term < ActiveRecord::Base
  belongs_to :course

  has_many :exercises, :dependent => :destroy
  has_many :tutorial_groups, :dependent => :destroy
  
  # has_many :tutors, :through => :tutorial_groups, :uniq => true, :include
  # has_many :tutors, :through => :tutorial_groups, :uniq => true
  
  has_one :lecturer_registrations, :dependent => :destroy
  delegate :lecturer, :to => :lecturer_registrations

  attr_accessible :title, :description, :course, :course_id, :exercises

  validates_presence_of :title, :course_id
  validates_uniqueness_of :title

  has_many :student_imports, :dependent => :destroy, :class_name => "Import::StudentImport"
  
  def tutors
    Account.joins(:tutor_registrations => {:tutorial_group => :term}).where{ tutor_registrations.tutorial_group.term.id == my{id}}
    
    tutorial_groups.student_registrations.students
  end

  def students
    Account.joins(:student_registrations => {:tutorial_group => :term}).where{ student_registrations.tutorial_group.term.id == my{id}}
  end
end
