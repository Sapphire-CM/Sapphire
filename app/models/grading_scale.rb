# create_table :grading_scales, force: :cascade do |t|
#   t.integer  :term_id
#   t.string   :grade,                      null: false
#   t.boolean  :not_graded, default: false, null: false
#   t.boolean  :positive,   default: true,  null: false
#   t.integer  :min_points, default: 0,     null: false
#   t.integer  :max_points, default: 0,     null: false
#   t.datetime :created_at,                 null: false
#   t.datetime :updated_at,                 null: false
# end
#
# add_index :grading_scales, [:grade], name: :index_grading_scales_on_grade
# add_index :grading_scales, [:term_id, :grade], name: :index_grading_scales_on_term_id_and_grade, unique: true
# add_index :grading_scales, [:term_id], name: :index_grading_scales_on_term_id

class GradingScale < ActiveRecord::Base
  belongs_to :term

  validates :grade, uniqueness: { scope: :term_id }
  validates :min_points, uniqueness: { scope: :term_id }, if: :not_graded?
  validates :max_points, uniqueness: { scope: :term_id }, if: :not_graded?
  validate :validate_point_range

  scope :ordered, lambda { order(:not_graded).order(:grade) }
  scope :positives, lambda { where(positive: true, not_graded: false).ordered }
  scope :negative, lambda { find_by(positive: false, not_graded: false) }
  scope :not_graded, lambda { find_by(not_graded: true) }
  scope :for_grade, lambda { |grade| find_by(grade: grade) }
  scope :grades, lambda { where(not_graded: false) }

  private

  def validate_point_range
    errors.add :min_points, 'min_points must be less than or equal to max_points' if min_points > max_points
    errors.add :max_points, 'max_points must be greater than or equal to min_points' if max_points < min_points
  end
end
