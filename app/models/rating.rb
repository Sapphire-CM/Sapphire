class Rating < ActiveRecord::Base
  belongs_to :rating_group
  
  has_one :exercise, through: :rating_group
  has_many :evalutions

  validates_presence_of :title, :type

  attr_accessible :title, :description, :rating_group, :value, :min_value, :max_value, :type

  def initialize(*args)
    unless args[0] == false
      raise "Cannot directly instantiate a Rating" if self.class == Rating
      super
    end

    super
  end
  
  def build_evaluation
    evaluation = if self.is_a? BinaryRating
      BinaryEvaluation.new
    else
      ValueEvaluation.new
    end
    
    evaluation.rating = self
    
    evaluation
  end
end
