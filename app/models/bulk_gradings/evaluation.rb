class BulkGradings::Evaluation
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :rating, :value, :item

  delegate :id, to: :rating, prefix: true
  delegate :exercise, :bulk, to: :item

  validates :rating, :item, presence: true
  validate :validate_value

  def rating_id=(id)
    @rating = bulk.rating_with_id(id)
  end

  def value?
    case rating
    when Ratings::FixedRating then fixed_value?
    when Ratings::VariableRating then variable_value?
    end
  end

  def save
    item.evaluation_for_rating(rating).update(value: value)
  end

  private

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

  def fixed_value?
    value.present?
  end

  def variable_value?
    value.present? && value != "0" && value != 0
  end
end