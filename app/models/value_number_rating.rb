class ValueNumberRating < Rating
  validates_presence_of :max_value, :min_value
  validate :all_values_range
  attr_accessible :max_value, :min_value

  def all_values_range
    if max_value && min_value && max_value < min_value
      errors.add :base, 'maximum value must be greater than minimum value'
    end
  end
end
