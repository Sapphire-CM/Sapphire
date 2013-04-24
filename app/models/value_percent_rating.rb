class ValuePercentRating < Rating
  # value counts as follows:
  #  70  => total_value * (1 +  (70/100))
  # -30  => total_value * (1 + (-30/100))

  validates_presence_of :max_value, :min_value
  attr_accessible :max_value, :min_value
end
