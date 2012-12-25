class Course < ActiveRecord::Base
  attr_accessible :description, :course_leader_id, :title

  belongs_to :course_leader

  has_many :terms, :dependent => :destroy
  
  validates_presence_of :title
  validates_uniqueness_of :title
  
  def active_term
    terms.active
  end
end
