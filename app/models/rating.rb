class Rating < ActiveRecord::Base
  belongs_to :rating_group

  validates_presence_of :title, :points

  attr_accessible :title, :points, :rating_group
end
