class Rating < ActiveRecord::Base
  belongs_to :rating_group

  include RankedModel
  ranks :row_order, with_same: :rating_group_id, class_name: 'Rating'

  default_scope { includes(:rating_group).rank(:row_order) }

  has_one :exercise, through: :rating_group
  has_many :evaluations, dependent: :destroy
  has_many :submission_evaluations, through: :evaluations

  validates :rating_group, presence: true
  validates :title, presence: true
  validates :type, presence: true

  validate :rating_type_validation

  after_create :create_evaluations
  after_update :update_evaluations, if: lambda { |rating| rating.value_changed? || rating.max_value_changed? || rating.min_value_changed? || rating.multiplication_factor_changed? }
  after_update :move_evaluations, if: lambda { |rating| rating.rating_group_id_changed? }

  scope :automated_ratings, lambda { where { !automated_checker_identifier.nil? && automated_checker_identifier != '' } }

  def initialize(*args)
    super *args
    self.multiplication_factor ||= 1.0
  end

  def self.new_from_type(params)
    classes = [BinaryNumberRating, BinaryPercentRating, ValueNumberRating, ValuePercentRating, PlagiarismRating]
    rating_class_index = classes.map(&:name).index(params[:type].classify)
    classes[rating_class_index].new(params.except(:type))
  end

  def evaluation_class
    fail NotImplementedError
  end

  def rating_type_validation
    errors.add(:type, 'must be a specific rating') if type == 'Rating'
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

  def automatically_checked?
    automated_checker_identifier.present?
  end

  private

  def create_evaluations
    Evaluation.create_for_rating(self)
  end

  def update_evaluations
    evaluations.each(&:update_result!)
  end

  def move_evaluations
    evaluations.each do |evaluation|
      submission_evaluation = evaluation.submission_evaluation

      evaluation_group = evaluation.evaluation_group
      new_evaluations_group = submission_evaluation.evaluation_groups.where(rating_group_id: rating_group_id).first

      evaluation.evaluation_group = new_evaluations_group
      evaluation.save!

      evaluation_group.update_result!
      new_evaluations_group.update_result!
    end
  end
end
