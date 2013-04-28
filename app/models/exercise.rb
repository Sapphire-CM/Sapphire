class Exercise < ActiveRecord::Base
  belongs_to :term
  
  has_many :submissions
  has_many :rating_groups, dependent: :nullify # Todo: thats correct? what else to do?
  has_many :ratings, through: :rating_groups
  
  validates_presence_of :title

  attr_accessible :title, :description, :term, :deadline, :late_deadline
end
