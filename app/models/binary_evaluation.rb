class BinaryEvaluation < Evaluation
  def checked?
    value == 1
  end

  def points
    if value == 1 && rating.is_a?(BinaryNumberRating)
      rating.value
    else
      0
    end
  end

  def percent
    if value == 1 && rating.is_a?(BinaryPercentRating)
      1 + rating.value.to_f/100.0
    else
      1
    end
  end
end
