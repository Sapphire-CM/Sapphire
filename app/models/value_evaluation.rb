class ValueEvaluation < Evaluation
  attr_accessible :value
  validate :value_range

  def value_range
    if value && rating && (rating.is_a? ValueNumberRating || rating.is_a? ValuePercentRating)
      if value < rating.min_value || value > rating.max_value
        errors.add :base, "value must be between #{rating.min_value} and #{rating.max_value}"
      end
    end
  end
end
