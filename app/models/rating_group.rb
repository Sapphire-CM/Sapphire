# create_table :rating_groups, force: :cascade do |t|
#   t.integer  :exercise_id
#   t.string   :title
#   t.integer  :points
#   t.datetime :created_at,                          null: false
#   t.datetime :updated_at,                          null: false
#   t.text     :description
#   t.boolean  :global,              default: false, null: false
#   t.integer  :min_points
#   t.integer  :max_points
#   t.boolean  :enable_range_points, default: false, null: false
#   t.integer  :row_order
# end
#
# add_index :rating_groups, [:exercise_id], name: :index_rating_groups_on_exercise_id
# add_index :rating_groups, [:title, :exercise_id], name: :index_rating_groups_on_title_and_exercise_id, unique: true

class RatingGroup < ActiveRecord::Base
  include RankedModel
  ranks :row_order, with_same: :exercise_id

  belongs_to :exercise
  has_many :ratings, dependent: :destroy
  has_many :evaluation_groups, dependent: :destroy

  validates :exercise, presence: true
  validates :title, presence: true, uniqueness: { scope: :exercise_id }
  validates :points, presence: true, unless: proc { |rating_group|
    rating_group.global == true
  }

  validate :min_max_points_range, :points_in_range

  after_create :create_evaluation_groups
  after_save :update_exercise_points, if: lambda { |rg| rg.points_changed? || rg.max_points_changed? }

  def update_exercise_points
    exercise.update_points!
  end

  after_update :update_evaluation_group_results, if: lambda { |rating_group| rating_group.points_changed? || rating_group.min_points_changed? || rating_group.max_points_changed? || rating_group.global_changed? }

  after_initialize do
    begin
      if try(:enable_range_points)
        if points > 0
          self.min_points ||= 0
          self.max_points ||= points
        else
          self.min_points ||= points
          self.max_points ||= 0
        end
      else
        self.min_points = nil
        self.max_points = nil
      end
    rescue
      # fixme!!!
    end
  end

  def min_max_points_range
    errors.add :min_points, 'minimum points must be less than maximum points'  if self.max_points && self.min_points && self.max_points < self.min_points
  end

  def points_in_range
    errors.add :points, 'must be between minimum points and maximum points' if self.min_points && self.max_points && ! (self.min_points..self.max_points).include?(points)
  end

  private

  def update_evaluation_group_results
    evaluation_groups.each(&:update_result!)
  end

  def create_evaluation_groups
    exercise.submission_evaluations.each do |se|
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
