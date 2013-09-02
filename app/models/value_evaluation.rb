class ValueEvaluation < Evaluation
  attr_accessible :value
  validate :value_range


  def points
    if self.rating.is_a?(ValueNumberRating)
      self.value
    else
      0
    end
  end

  def percent
    if self.rating.is_a?(ValuePercentRating)
      1 + evaluation.value.to_f/100.0
    else
      1
    end
  end

  def value_range
    if value && rating.is_a?(ValueRating)
      if value < rating.min_value || value > rating.max_value
        errors.add :base, "value must be between #{rating.min_value} and #{rating.max_value}"
      end
    end
  end
end
