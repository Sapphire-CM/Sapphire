class TutorTermRegistration < ActiveRecord::Base
  belongs_to :account
  belongs_to :tutorial_group
  
  has_one :term, :through => :tutorial_group
  has_one :course, :through => :term
  
  attr_accessible :registered_at

  def tutor
    account
  end
end