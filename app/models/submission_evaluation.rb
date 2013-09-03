class SubmissionEvaluation < ActiveRecord::Base
  belongs_to :submission
  belongs_to :evaluator, polymorphic: true

  has_one :student_group, through: :submission

  has_many :evaluation_groups, dependent: :destroy
  has_many :ratings, through: :evaluations
  has_many :rating_groups, through: :ratings

  validates_uniqueness_of :submission_id
  validates_presence_of :evaluated_at

  after_create :create_evaluation_groups

  def calc_results!
    calc_results
    self.save!
  end

  private
  def calc_results
    final_sum = 0
    percent = 1

    self.evaluation_groups.each do |eval_group|
      final_sum += eval_group.points
      percent *= eval_group.percent
    end


    final_sum = final_sum.to_f * percent
    final_sum = 0 if final_sum < 0

    self.evaluation_result = final_sum
  end

  def create_evaluation_groups
    EvaluationGroup.create_for_submission_evaluation(self)
  end
end
