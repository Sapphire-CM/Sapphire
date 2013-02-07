class RatingGroup < ActiveRecord::Base
  belongs_to :exercise

  has_many :ratings, :dependent => :destroy

  attr_accessible :points, :title, :exercise
end
