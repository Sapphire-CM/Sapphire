class StudentTermRegistration < ActiveRecord::Base
  belongs_to :account
  belongs_to :term
  
  has_one :course, :through => :term
  
  attr_accessible :registered_at

  def student
    account
  end
end