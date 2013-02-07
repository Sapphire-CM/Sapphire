class Exercise < ActiveRecord::Base
  belongs_to :term

  has_many :rating_groups, :dependent => :nullify # Todo: thats correct? what else to do?
  validates_presence_of :title

  attr_accessible :title, :term
end
