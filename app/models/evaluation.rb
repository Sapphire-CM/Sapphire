class Evaluation < ActiveRecord::Base
  belongs_to :student
  belongs_to :rating

  def initialize(args = nil)
    raise "Cannot directly instantiate a Evaluation" if self.class == Evaluation
    super
  end
end
