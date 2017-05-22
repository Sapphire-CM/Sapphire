module RatingsHelper
  def ratings_form_collection
    [
      ['Fixed Points Deduction',     Ratings::FixedPointsDeductionRating.name],
      ['Fixed Percentage Deduction', Ratings::FixedPercentageDeductionRating.name],
      ['Variable Points Deduction',     Ratings::VariablePointsDeductionRating.name],
      ['Variable Percentage Deduction', Ratings::VariablePercentageDeductionRating.name],
      ['Per Item Points Deduction', Ratings::PerItemPointsDeductionRating.name],
      ['Fixed Bonus Points', Ratings::FixedBonusPointsRating.name],
      ['Variable Bonus Points', Ratings::VariableBonusPointsRating.name],
      ['Plagiarism',         Ratings::PlagiarismRating.name]
    ]
  end

  def rating_points_description(rating)
    case rating
    when Ratings::FixedPointsDeductionRating, Ratings::FixedBonusPointsRating
      "#{rating.value}"
    when Ratings::FixedPercentageDeductionRating
      "#{rating.value} %"
    when Ratings::VariablePointsDeductionRating, Ratings::VariableBonusPointsRating
      "#{rating.min_value} ... #{rating.max_value}"
    when Ratings::PerItemPointsDeductionRating
      "#{rating.min_value} ... #{rating.max_value} (× #{number_to_human rating.multiplication_factor})"
    when Ratings::VariablePercentageDeductionRating
      "#{rating.min_value} ... #{rating.max_value} %"
    end
  end

  def automated_checks_form_collection
    Sapphire::AutomatedCheckers::Central.registered_checkers.inject([]) do |groups, checker|
      groups << checker
    end
  end

  def automated_check_title(identifier)
    if check = Sapphire::AutomatedCheckers::Central.check_for_identifier(identifier)
      "#{check.title} (#{check.checker_class.title})"
    else
      'unknown'
    end
  end
end
