class BinaryPercentRating < Rating
  # value counts as follows:
  #  70  => total_value * (1 +  (70/100))
  # -30  => total_value * (1 + (-30/100))

  attr_accessible :value
end
