class Rating < ActiveRecord::Base
  belongs_to :rating_group

  attr_accessible :points, :title, :rating_group
end
