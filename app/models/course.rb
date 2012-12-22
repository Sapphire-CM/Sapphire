class Course < ActiveRecord::Base
  attr_accessible :description, :course_leader_id, :title

  belongs_to :course_leader

  has_many :terms
  has_many :student_imports
  
  validates_presence_of :title, :course_leader_id
  
  
  def active_term
    terms.active
  end
end
