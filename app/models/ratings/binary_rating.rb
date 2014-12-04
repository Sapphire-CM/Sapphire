class BinaryRating < Rating
  validates :value, presence: true

  def initialize(*args)
    raise "Cannot directly instantiate a BinaryRating" if self.class == BinaryRating
    super
  end

  def evaluation_class
    BinaryEvaluation
  end
end
