class BinaryRating < Rating
  attr_accessible :value

  def initialize(*args)
    raise "Cannot directly instantiate a BinaryRating" if self.class == BinaryRating
    super
  end
end
