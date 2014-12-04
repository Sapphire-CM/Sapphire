class RatingGroup < ActiveRecord::Base
  include RankedModel
  ranks :row_order, with_same: :exercise_id

  belongs_to :exercise
  has_many :ratings, dependent: :destroy
  has_many :evaluation_groups, dependent: :destroy

  validates :exercise, presence: true
  validates :title, presence: true, uniqueness: { scope: :exercise }
  validates :points, presence: true, unless: Proc.new { |rating_group|
    rating_group.global == true
  }

  validate :min_max_points_range, :points_in_range

  after_create :create_evaluation_groups
  after_save :update_exercise_points, if: lambda { |rg| rg.points_changed? || rg.max_points_changed? }

  def update_exercise_points
    exercise.update_points!
  end

  after_initialize :points_min_max
  after_update :update_evaluation_group_results, if: lambda {|rating_group| rating_group.points_changed? || rating_group.min_points_changed? || rating_group.max_points_changed? || rating_group.global_changed?}

  def points_min_max
    if self.try(:enable_range_points)
      if points > 0
        self.min_points ||= 0
        self.max_points ||= self.points
      else
        self.min_points ||= self.points
        self.max_points ||= 0
      end
    else
      self.min_points = nil
      self.max_points = nil
    end
  rescue
    nil
    # fixme!!!
  end

  def min_max_points_range
    errors.add :min_points, 'minimum points must be less than maximum points'  if self.max_points && self.min_points && self.max_points < self.min_points
  end

  def points_in_range
    errors.add :points, 'must be between minimum points and maximum points' if self.min_points && self.max_points && ! (self.min_points..self.max_points).include?(self.points)
  end

  private
  def update_evaluation_group_results
    self.evaluation_groups.each(&:update_result!)
  end

  def create_evaluation_groups
    self.exercise.submission_evaluations.each do |se|
      EvaluationGroup.create_for_submission_evaluation_and_rating_group(se, self)
    end
  end

  # global: true     if there is no maximum points for this group, therefore all
  #                  ratings count directly to the whole exercise
  #         false    if the ratings only can substract from the specified maximum
  #                  points for this rating_group.
  #         example  Plagiarism:         -50%
  #                  late deadline:      -50%
  #                  misc. subtractions: -42 points
  #                  misc. bonus:        +21 points

end
