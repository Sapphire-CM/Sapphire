class Rating < ActiveRecord::Base
  belongs_to :rating_group
  attr_accessible :title, :description, :rating_group, :rating_group_id, :value, :min_value, :max_value, :type, :row_order_position

  include RankedModel
  ranks :row_order, with_same: :rating_group_id, class_name: "Rating"

  default_scope { includes(:rating_group).rank(:row_order) }

  has_one :exercise, through: :rating_group
  has_many :evaluations
  has_many :submission_evaluations, through: :evaluations

  validates_presence_of :title, :type

  validate :rating_type_validation

  after_update :update_evaluations, if: lambda {|rating| rating.value_changed? || rating.max_value_changed? || rating.min_value_changed?}
  after_update :move_evaluations, id: lambda {|rating| rating.rating_group_id_changed? }

  # def initialize(*args)
  #   unless args[0] == false
  #     raise "Cannot directly instantiate a Rating" if self.class == Rating
  #     super
  #   end
  #
  #   super
  # end

  def evaluation_class
    raise NotImplementedError
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

  private
  def update_evaluations
    self.evaluations.each(&:update_result!)
  end

  def move_evaluations
    self.evaluations.each do |evaluation|
      submission_evaluation = evaluation.submission_evaluation

      evaluation_group = evaluation.evaluation_group
      new_evaluations_group = submission_evaluation.evaluation_groups.where(rating_group_id: self.rating_group_id).first

      evaluation.evaluation_group = new_evaluations_group
      evaluation.save!

      evaluation_group.update_result!
      new_evaluations_group.update_result!
    end
  end
end
