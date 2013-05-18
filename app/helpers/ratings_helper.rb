module RatingsHelper
  def ratings_form_collection
    [['Boolean Points', BinaryNumberRating.name],['Boolean Percentage', BinaryPercentRating.name], ['Min/Max Points', ValueNumberRating.name], ['Min/Max Percentage', ValuePercentRating.name]]
  end
end
