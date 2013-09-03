class BinaryRating < Rating
  attr_accessible :value

  validates_presence_of :value

  def initialize(*args)
    raise "Cannot directly instantiate a BinaryRating" if self.class == BinaryRating
    super
  end

  def evaluation_class
    BinaryEvaluation
  end
end
