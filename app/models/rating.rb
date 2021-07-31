# create_table :ratings, force: :cascade do |t|
#   t.integer  :rating_group_id
#   t.string   :title
#   t.integer  :value
#   t.datetime :created_at,                                   null: false
#   t.datetime :updated_at,                                   null: false
#   t.text     :description
#   t.string   :type
#   t.integer  :max_value
#   t.integer  :min_value
#   t.integer  :row_order
#   t.float    :multiplication_factor
#   t.string   :automated_checker_identifier
#   t.boolean  :bulk,                         default: false
# end
#
# add_index :ratings, [:rating_group_id], name: :index_ratings_on_rating_group_id

class Rating < ActiveRecord::Base
  belongs_to :rating_group, touch: true

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

  after_save :evaluations_need_review!, if: lambda { |rating| rating.title_changed? || rating.value_changed? || rating.max_value_changed? || rating.min_value_changed? || rating.multiplication_factor_changed? }

  scope :automated_ratings, lambda {
    scopes = [
      arel_table[:automated_checker_identifier].not_eq(nil),
      arel_table[:automated_checker_identifier].not_eq("")
    ]

    where(scopes.reduce(&:and))
  }

  scope :bulk, lambda { where(bulk: true) }

  after_initialize do
    self.multiplication_factor ||= 1.0 if attribute_present? :multiplication_factor
  end

  def self.instantiable_subclasses
    [
      Ratings::FixedPointsDeductionRating,
      Ratings::FixedPercentageDeductionRating,
      Ratings::VariablePointsDeductionRating,
      Ratings::VariablePercentageDeductionRating,
      Ratings::PerItemPointsRating,
      Ratings::PerItemPointsDeductionRating,
      Ratings::FixedBonusPointsRating,
      Ratings::VariableBonusPointsRating,
      Ratings::PlagiarismRating
    ]
  end

  def self.new_from_type(params)
    classes = instantiable_subclasses

    klass = classes.find { |klass| klass.name == params[:type].classify }
    klass.new(params.except(:type))
  end

  def self.valid_type?(type)
    instantiable_subclasses.map(&:to_s).include?(type.to_s)
  end

  def evaluation_class
    fail NotImplementedError
  end

  def rating_type_validation
    errors.add(:type, 'must be a specific rating') if type == 'Rating'
  end

  def automatically_checked?
    automated_checker_identifier.present?
  end

  def from_updated_type
    subclass = self.class.instantiable_subclasses.find { |klass| klass.name == self.type}

    if subclass
      becomes(subclass)
    else
      raise ArgumentError.new("Unknown Subclass: #{type}")
    end
  end

  def points_value?
    evaluation_value_type == :points
  end

  def percentage_value?
    evaluation_value_type == :percentage
  end

  def policy_class
    RatingPolicy
  end

  protected
  def evaluation_value_type
    raise NotImplementedError
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
      new_evaluations_group = submission_evaluation.evaluation_groups.find_by(rating_group_id: rating_group_id)

      evaluation.evaluation_group = new_evaluations_group
      evaluation.save!

      evaluation_group.update_result!
      new_evaluations_group.update_result!
    end
  end

  def evaluations_need_review!
    evaluations.find_each do |evaluation|
      evaluation.update(needs_review: true)
    end
  end
end
