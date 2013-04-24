class Rating < ActiveRecord::Base
  belongs_to :rating_group
  has_many :evalutions

  validates_presence_of :title, :type

  attr_accessible :title, :description, :value

  def initialize(args = nil)
    raise "Cannot directly instantiate a Rating" if self.class == Rating
    super
  end
end
