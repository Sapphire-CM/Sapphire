class Exercise < ActiveRecord::Base
  belongs_to :term
  attr_accessible :title, :description, :term, :term_id, :deadline, :late_deadline, :enable_max_points, :max_points, :submission_time, :row_order_position, :group_submission

  include RankedModel
  ranks :row_order, with_same: :term_id

  default_scope { rank(:row_order) }

  has_many :student_group_registrations, dependent: :destroy

  has_many :submissions
  has_many :rating_groups, dependent: :destroy
  has_many :ratings, through: :rating_groups

  validates_presence_of :title
  validates_presence_of :max_points, unless: Proc.new { ! self.enable_max_points }

end
