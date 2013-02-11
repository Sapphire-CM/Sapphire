class Tutor < ActiveRecord::Base
  attr_accessible :forename, :surname, :fullname


  has_one :account, :as => :accountable
  has_many :tutorial_groups
end
