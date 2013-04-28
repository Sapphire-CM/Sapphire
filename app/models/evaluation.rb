class Evaluation < ActiveRecord::Base
  belongs_to :student
  belongs_to :rating
  
  has_one :rating_group, through: :rating
  
  attr_accessible :rating_id, :type, :value
  
  def initialize(*args)
    raise "Cannot directly instantiate a Evaluation" if self.class == Evaluation if !args[0].nil? && args[0][:type].blank?
    super
  end
end
