# create_table :submission_evaluations, force: :cascade do |t|
#   t.integer  :submission_id
#   t.integer  :evaluator_id
#   t.string   :evaluator_type
#   t.datetime :evaluated_at
#   t.datetime :created_at,                        null: false
#   t.datetime :updated_at,                        null: false
#   t.integer  :evaluation_result
#   t.boolean  :plagiarized,       default: false, null: false
#   t.boolean  :needs_review,      default: false
# end
#
# add_index :submission_evaluations, [:evaluator_id], name: :index_submission_evaluations_on_evaluator_id
# add_index :submission_evaluations, [:submission_id], name: :index_submission_evaluations_on_submission_id, unique: true

class SubmissionEvaluation < ActiveRecord::Base
  belongs_to :submission
  belongs_to :evaluator, class_name: 'Account'

  has_one :student_group, through: :submission

  has_many :evaluation_groups, dependent: :destroy, inverse_of: :submission_evaluation
  has_many :evaluations, through: :evaluation_groups

  has_many :ratings, through: :evaluations
  has_many :rating_groups, through: :ratings

  validates :submission, presence: true
  validates :submission_id, uniqueness: true

  scope :evaluated, lambda { where.not(evaluator: nil) }
  scope :not_evaluated, lambda { where(evaluator: nil) }

  after_create :create_evaluation_groups
  after_save :update_exercise_results, if: :evaluation_result_changed?

  def calc_results!
    calc_results
    self.save!
  end

  def update_plagiarized!
    plagiarized = evaluations.joins { rating }
      .where.not(value: 0)
      .where { rating.type == Ratings::PlagiarismRating }
      .exists?
    self.plagiarized = plagiarized
    self.save!
  end

  def update_exercise_results
    submission.exercise_registrations.each(&:update_points!)

    submission.student_group.update_points! if submission.student_group.present?
    true
  end

  def evaluation_for_rating(rating)
    evaluations.find_by_rating_id(rating.id)
  end

  def update_needs_review!
    update(needs_review: evaluation_groups.needing_review.exists?)
  end

  private
  def calc_results
    final_sum = 0
    percent = 1

    evaluation_groups(true).each do |eval_group|
      final_sum += eval_group.points || 0
      percent *= eval_group.percent || 1
    end

    final_sum = final_sum.to_f * percent
    if final_sum < 0
      final_sum = 0
    end

    if submission.exercise.enable_max_total_points && final_sum > submission.exercise.max_total_points
      final_sum = submission.exercise.max_total_points
    end

    self.evaluation_result = final_sum
  end

  def create_evaluation_groups
    EvaluationGroup.create_for_submission_evaluation(self)
    calc_results!
  end
end
