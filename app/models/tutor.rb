class Tutor < ActiveRecord::Base
  include Naming # defined in lib/sapphire/naming
  
  attr_accessible :forename, :surname

  has_one :account, :as => :accountable
  has_many :tutorial_groups
  
end
