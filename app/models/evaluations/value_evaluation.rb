class ValueEvaluation < Evaluation
  validate :value_range

  def points
    if value.present? && rating.is_a?(ValueNumberRating)
      value * rating.multiplication_factor
    else
      0
    end
  end

  def percent
    if value.present? && rating.is_a?(ValuePercentRating)
      1 + value.to_f / 100.0
    else
      1
    end
  end

  def value_range
    return unless value.present? && rating.is_a?(ValueRating)

    if value < rating.min_value || value > rating.max_value
      errors.add :base, "value must be between #{rating.min_value} and #{rating.max_value}"
    end
  end
end
