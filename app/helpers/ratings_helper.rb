module RatingsHelper
  def ratings_form_collection
    [
      ['Boolean Points',     Ratings::BinaryNumberRating.name],
      ['Boolean Percentage', Ratings::BinaryPercentRating.name],
      ['Min/Max Points',     Ratings::ValueNumberRating.name],
      ['Min/Max Percentage', Ratings::ValuePercentRating.name],
      ['Plagiarism',         Ratings::PlagiarismRating.name]
    ]
  end

  def rating_points_description(rating)
    if rating.is_a? Ratings::BinaryNumberRating
      "#{rating.value}"
    elsif rating.is_a? Ratings::BinaryPercentRating
      "#{rating.value} %"
    elsif rating.is_a? Ratings::ValueNumberRating
      "#{rating.min_value} ... #{rating.max_value}"
    elsif rating.is_a? Ratings::ValuePercentRating
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
