class Term < ActiveRecord::Base
  belongs_to :course
  has_many :tutorial_groups, :dependent => :destroy
  has_many :term_registration, :dependent => :destroy
  
  attr_accessible :active, :course, :title
  
  validates_uniqueness_of :active, :scope => :course_id, :if => lambda {|term| term.active? }
  
  after_create :make_active!
  
  
  
  
  def self.active
    where(:active => true).first
  end
  
  def make_active!
    self.class.where(:course_id => self.course_id).update_all(:active => false)
    self.active = true
    save! unless new_record?
  end
end
