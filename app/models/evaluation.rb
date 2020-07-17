# create_table :evaluations, force: :cascade do |t|
#   t.boolean  :checked,               default: false, null: false
#   t.integer  :rating_id
#   t.datetime :created_at,                            null: false
#   t.datetime :updated_at,                            null: false
#   t.string   :type
#   t.integer  :value
#   t.integer  :evaluation_group_id
#   t.boolean  :checked_automatically, default: false, null: false
#   t.boolean  :needs_review,          default: false
# end
#
# add_index :evaluations, [:evaluation_group_id], name: :index_evaluations_on_evaluation_group_id
# add_index :evaluations, [:rating_id], name: :index_evaluations_on_rating_id

class Evaluation < ActiveRecord::Base
  include Commentable

  belongs_to :evaluation_group, touch: true
  belongs_to :rating

  has_one :submission_evaluation, through: :evaluation_group
  has_one :student_group, through: :submission_evaluation
  has_one :submission, through: :submission_evaluation
  has_one :rating_group, through: :evaluation_group

  has_many_comments :explanations

  validates :evaluation_group, presence: true
  validates :rating, presence: true
  validate :validate_evaluation_type

  after_create :update_result!
  after_update :update_result!, if: lambda { |evaluation| evaluation.value_changed? }
  after_update :update_needs_review!, if: :needs_review_changed?

  after_destroy :update_result!
  after_destroy :update_needs_review!

  scope :ranked, lambda { includes(:rating).order { rating.row_order.asc }.references(:rating) }

  scope :needing_review, lambda { where(needs_review: true) }
  scope :for_submission, lambda { |submission| joins { evaluation_group.submission_evaluation }.where { evaluation_group.submission_evaluation.submission_id == my { submission.id } }.readonly(false) }
  scope :for_exercise, lambda { |exercise| joins { submission }.where { submission.exercise_id == my { exercise.id } } }
  scope :automatically_checked, lambda { where { checked_automatically == true } }

  delegate :row_order, to: :rating

  def self.create_for_evaluation_group(evaluation_group)
    evaluation_group.evaluations = evaluation_group.rating_group.ratings.map do |rating|
      rating.evaluation_class.new(rating: rating)
    end
  end

  def self.create_for_rating(rating)
    rating.rating_group.evaluation_groups.each do |eval_group|
      evaluation = new(rating: rating, type: rating.evaluation_class.to_s).becomes(rating.evaluation_class)
      eval_group.evaluations << evaluation
    end
  end

  def points
    0
  end

  def percent
    1
  end

  def update_result!
    evaluation_group.update_result!

    submission_evaluation.update_plagiarized! if rating.is_a?(Ratings::PlagiarismRating)
  end

  def show_to_students?
    raise NotImplementedError
  end

  private

  def update_needs_review!
    evaluation_group.update_needs_review!
  end

  def validate_evaluation_type
    errors[:type] = 'must not be Evaluation' if type == 'Evaluation'
  end
end
