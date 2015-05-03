class GradingScale < ActiveRecord::Base
  belongs_to :term

  validates :grade, uniqueness: { scope: :term_id }
  validates :min_points, uniqueness: { scope: :term_id }, if: :not_graded?
  validates :max_points, uniqueness: { scope: :term_id }, if: :not_graded?
  validate :validate_point_range

  scope :ordered, lambda { order(:grade) }
  scope :positives, lambda { where(positive: true) }
  scope :negatives, lambda { where(positive: false) }
  scope :for_grade, lambda { |grade| where(grade: grade).first }

  private

  def validate_point_range
    errors.add :min_points, 'min_points must be less than or equal to max_points' if min_points > max_points
    errors.add :max_points, 'max_points must be greater than or equal to min_points' if max_points < min_points
  end
end
