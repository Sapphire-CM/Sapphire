# create_table :evaluations, force: :cascade do |t|
#   t.boolean  :checked,               default: false, null: false
#   t.integer  :rating_id
#   t.datetime :created_at,                            null: false
#   t.datetime :updated_at,                            null: false
#   t.string   :type
#   t.integer  :value
#   t.integer  :evaluation_group_id
#   t.boolean  :checked_automatically, default: false, null: false
# end
#
# add_index :evaluations, [:evaluation_group_id], name: :index_evaluations_on_evaluation_group_id, using: :btree
# add_index :evaluations, [:rating_id], name: :index_evaluations_on_rating_id, using: :btree

class Evaluation < ActiveRecord::Base
  belongs_to :evaluation_group
  belongs_to :rating

  has_one :submission_evaluation, through: :evaluation_group
  has_one :student_group, through: :submission_evaluation
  has_one :submission, through: :submission_evaluation
  has_one :rating_group, through: :evaluation_group

  validates :evaluation_group, presence: true
  validates :rating, presence: true
  validate :validate_evaluation_type

  after_create :update_result!, if: lambda { |eval| eval.value_changed? }
  after_update :update_result!, if: lambda { |eval| eval.value_changed? }
  after_destroy :update_result!

  scope :ranked, lambda { includes(:rating).order { rating.row_order.asc }.references(:rating) }

  scope :for_submission, lambda { |submission| joins { evaluation_group.submission_evaluation }.where { evaluation_group.submission_evaluation.submission_id == my { submission.id } }.readonly(false) }
  scope :for_exercise, lambda { |exercise| joins { submission }.where { submission.exercise_id == my { exercise.id } } }
  scope :automatically_checked, lambda { where { checked_automatically == true } }

  def self.create_for_evaluation_group(evaluation_group)
    evaluation_group.rating_group.ratings.each do |rating|
      evaluation = new_from_rating(rating)
      evaluation.evaluation_group = evaluation_group
      evaluation.save!
    end
  end

  def self.create_for_rating(rating)
    rating.rating_group.evaluation_groups.each do |eval_group|
      evaluation = new_from_rating(rating)
      evaluation.evaluation_group = eval_group
      evaluation.save!
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

  private

  def self.new_from_rating(rating)
    evaluation = rating.evaluation_class.new
    evaluation.rating = rating
    evaluation
  end

  def validate_evaluation_type
    errors[:type] = 'must not be Evaluation' if type == 'Evaluation'
  end
end
