# create_table :evaluation_groups, force: :cascade do |t|
#   t.integer  :points
#   t.float    :percent
#   t.integer  :rating_group_id
#   t.integer  :submission_evaluation_id
#   t.datetime :created_at,                               null: false
#   t.datetime :updated_at,                               null: false
#   t.integer  :status,                   default: 0,     null: false
#   t.boolean  :needs_review,             default: false
# end
#
# add_index :evaluation_groups, [:rating_group_id], name: :index_evaluation_groups_on_rating_group_id
# add_index :evaluation_groups, [:submission_evaluation_id], name: :index_evaluation_groups_on_submission_evaluation_id

class EvaluationGroup < ActiveRecord::Base
  belongs_to :rating_group
  belongs_to :submission_evaluation, touch: true, inverse_of: :evaluation_groups

  has_many :evaluations, dependent: :delete_all

  validates :rating_group, presence: true
  validates :submission_evaluation, presence: true

  after_create :create_evaluations
  after_update :update_submission_evaluation_results, if: lambda { |eg| eg.points_changed? || eg.percent_changed? }
  after_update :update_submission_evaluation_needs_review!, if: :needs_review_changed?
  after_destroy :update_submission_evaluation_results

  delegate :title, to: :rating_group

  scope :ranked, lambda { includes(:rating_group).order { rating_group.row_order.asc }.references(:rating_group) }

  scope :needing_review, lambda { where(needs_review: true) }

  enum status: { pending: 0, done: 1 }

  def self.create_for_submission_evaluation(submission_evaluation)
    submission_evaluation.submission.exercise.rating_groups.each do |rating_group|
      create_for_submission_evaluation_and_rating_group(submission_evaluation, rating_group)
    end
  end

  def self.create_for_submission_evaluation_and_rating_group(submission_evaluation, rating_group)
    eg = new
    eg.rating_group = rating_group
    eg.points = rating_group.points
    eg.submission_evaluation = submission_evaluation
    eg.save!
  end

  def update_result!
    calc_result
    self.save!
  end

  def calc_result
    points_sum = rating_group.points || 0
    percent_product = 1

    evaluations.includes(:rating).each do |evaluation|
      points_sum += evaluation.points
      percent_product *= evaluation.percent
    end

    if points_sum < (min_points = rating_group.min_points || 0)
      points_sum = min_points
    elsif points_sum > (max_points = rating_group.max_points || rating_group.points || 0)
      points_sum = max_points
    end

    if rating_group.global?
      self.points = points_sum
      self.percent = percent_product
    else
      self.points = (points_sum * percent_product).round.to_i
      self.percent = 1
    end

    true
  end

  def update_needs_review!
    update(needs_review: evaluations.needing_review.exists?)
  end

  private

  def update_submission_evaluation_results
    submission_evaluation.calc_results!
  end

  def update_submission_evaluation_needs_review!
    submission_evaluation.update_needs_review!
  end

  def create_evaluations
    Evaluation.create_for_evaluation_group(self)
    update_result!
  end
end
