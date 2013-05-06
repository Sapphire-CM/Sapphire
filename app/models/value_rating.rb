class ValueRating < Rating
  validates_presence_of :min_value, :max_value
  attr_accessible :min_value, :max_value
  validate :all_values_range

  def all_values_range
    if max_value && min_value && max_value < min_value
      errors.add :base, 'maximum value must be greater than minimum value'
    end
  end

  def initialize(*args)
    raise "Cannot directly instantiate a ValueRating" if self.class == ValueRating
    super
  end
end
