class Exercise < ActiveRecord::Base
  belongs_to :term

  has_many :rating_groups, :dependent => :nullify # Todo: thats correct? what else to do?

  attr_accessible :title, :term
end
