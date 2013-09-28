class Exercise < ActiveRecord::Base
  belongs_to :term
  attr_accessible :title, :description, :term, :term_id, :deadline, :late_deadline, :enable_max_points, :max_points, :submission_time, :group_exercise, :row_order_position, :group_submission

  include RankedModel
  ranks :row_order, with_same: :term_id

  default_scope { rank(:row_order) }
  scope :for_evaluations_table, lambda { includes(submissions: [{submission_evaluation: {evaluation_groups: [:rating_group, {evaluations: :rating}]}}, {student_group_registration: {student_group: :students}}])}

  has_many :student_group_registrations, dependent: :destroy
  has_many :student_groups, through: :student_group_registrations

  has_many :submissions
  has_many :submission_evaluations, through: :submissions
  has_many :rating_groups, dependent: :destroy
  has_many :ratings, through: :rating_groups

  validates_presence_of :title
  validates_presence_of :max_points, unless: Proc.new { ! self.enable_max_points }

  def update_points!
    self.points = self.reload.rating_groups.map{|rg| rg.max_points || rg.points}.compact.sum || 0
    self.save!
  end

  after_save :update_term_points, if: lambda { |ex| ex.points_changed? }

  def update_term_points
    term.update_points!
  end

end
