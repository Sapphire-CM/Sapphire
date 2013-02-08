class RatingGroup < ActiveRecord::Base
  belongs_to :exercise

  has_many :ratings, :dependent => :destroy
  validates_presence_of :title, :points

  attr_accessible :title, :description, :points, :exercise
end
