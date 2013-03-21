class Course < ActiveRecord::Base
  attr_accessible :title, :description

  has_many :terms, :dependent => :destroy

  validates_presence_of :title
  validates_uniqueness_of :title

end
