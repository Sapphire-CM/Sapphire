class BinaryEvaluation < Evaluation
  attr_accessible :checked

  def evaluation_class
    BinaryEvaluation
  end

  def points
    if value == 1 && self.rating.is_a?(BinaryNumberRating)
      self.rating.value
    else
      0
    end
  end

  def percent
    if value == 1 && self.rating.is_a?(BinaryPercentRating)
      1 + self.rating.value.to_f/100.0
    else
      1
    end
  end
end
