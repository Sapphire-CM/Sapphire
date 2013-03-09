class Evaluation < ActiveRecord::Base
  belongs_to :student
  belongs_to :rating

  attr_accessible :checked
end
