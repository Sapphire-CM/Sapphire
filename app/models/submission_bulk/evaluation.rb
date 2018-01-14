class SubmissionBulk::Evaluation
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :rating, :value, :evaluation, :item

  delegate :id, to: :rating, prefix: true
  delegate :exercise, :bulk, to: :item

  validates :rating, presence: true
  validate :validate_value

  def rating_id=(id)
    @rating = bulk.ratings.find { |rating| rating.id == id.to_i }
  end

  def validate_value
    if rating.present?
      validation_evaluation = rating.evaluation_class.new(value: value, rating: rating)

      unless validation_evaluation.valid?
        if (value_errors = validation_evaluation.errors[:value]).present?
          value_errors.each do |error|
            errors.add(:value, error)
          end
        end
      end
    end
  end

end