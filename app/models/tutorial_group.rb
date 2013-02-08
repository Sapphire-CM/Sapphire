class TutorialGroup < ActiveRecord::Base
  belongs_to :term

  attr_accessible :title, :tutor, :tutor_id
  
  validates_presence_of :title

  has_many :term_registrations, :dependent => :destroy
  has_many :students, :through => :term_registrations
  
end
