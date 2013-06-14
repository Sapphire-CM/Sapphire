class Rating < ActiveRecord::Base
  include RankedModel
  ranks :row_order, with_same: :rating_group_id, class_name: "Rating"

  default_scope includes(:rating_group).rank(:row_order)

  belongs_to :rating_group

  has_one :exercise, through: :rating_group
  has_many :evalutions

  validates_presence_of :title, :type

  attr_accessible :title, :description, :rating_group, :value, :min_value, :max_value, :type, :position

  validate :rating_type_validation

  # def initialize(*args)
  #   unless args[0] == false
  #     raise "Cannot directly instantiate a Rating" if self.class == Rating
  #     super
  #   end
  #
  #   super
  # end

  def self.new_from_type(params)

    classes = [BinaryNumberRating, BinaryPercentRating, ValueNumberRating, ValuePercentRating]

    rating_class_index = classes.map(&:name).index(params[:type])

    classes[rating_class_index].new(params.except(:type))
  end

  def rating_type_validation
    errors.add(:type, "must be a specific rating") if self.type == "Rating"
  end

  def build_evaluation
    evaluation = if self.is_a? BinaryRating
      BinaryEvaluation.new
    else
      ValueEvaluation.new
    end

    evaluation.rating = self

    evaluation
  end
end
