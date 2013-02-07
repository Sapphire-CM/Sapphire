class Term < ActiveRecord::Base
  belongs_to :course
  has_many :tutorial_groups, :dependent => :destroy
  has_many :term_registrations, :dependent => :destroy
  has_many :student_imports, :dependent => :destroy, :class_name => "Import::StudentImport"
  has_many :students, :through => :term_registrations
  has_many :exercises, :dependent => :destroy
  
  attr_accessible :active, :course_id, :title, :course, :exercises
  
  validates_presence_of :title, :course_id
  validates_uniqueness_of :active, :scope => :course_id, :if => lambda {|term| term.active? }
  after_create :make_active!
  
  scope :with_courses, joins(:course).includes(:course)
  
  def self.active
    where(:active => true).first
  end
  
  def make_active!
    self.class.where(:course_id => self.course_id).update_all(:active => false)
    self.active = true
    save! unless new_record?
  end
end
