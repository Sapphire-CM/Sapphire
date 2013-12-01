module RatingsHelper
  def ratings_form_collection
    [
      ['Boolean Points',     BinaryNumberRating.name],
      ['Boolean Percentage', BinaryPercentRating.name],
      ['Min/Max Points',     ValueNumberRating.name],
      ['Min/Max Percentage', ValuePercentRating.name],
      ['Plagiarism',         PlagiarismRating.name]
    ]
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
      "unknown"
    end
  end
end
