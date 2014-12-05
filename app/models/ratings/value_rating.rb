class ValueRating < Rating
  validates :min_value, presence: true
  validates :max_value, presence: true
  validate :all_values_range

  def evaluation_class
    ValueEvaluation
  end

  def all_values_range
    if max_value && min_value && max_value < min_value
      errors.add :min_value, 'maximum value must be greater than minimum value'
    end
  end

  def initialize(*args)
    raise "Cannot directly instantiate a ValueRating" if self.class == ValueRating
    super
  end
end
