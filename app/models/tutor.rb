class Tutor < ActiveRecord::Base
  attr_accessible :forename, :surname, :fullname

  has_many :tutorial_groups
end
