class ValueNumberRating < ValueRating
  # value counts as follows:
  #  7  => total_value + 7
  # -3  => total_value + (-3)

  def initialize(*args)
    super *args
    self.multiplication_factor ||= 1.0
  end
end
