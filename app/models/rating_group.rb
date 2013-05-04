class RatingGroup < ActiveRecord::Base
  belongs_to :exercise
  has_many :ratings, dependent: :destroy

  validates_presence_of :title
  validates_presence_of :points, unless: Proc.new { |rating_group|
    rating_group.global == true
  }


  attr_accessible :title, :description, :points, :exercise, :global, :enable_range_points, :min_points, :max_points

  validate :min_max_points_range, :points_in_range

  after_initialize :points_min_max

  def points_min_max
    if enable_range_points
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
  end

  def min_max_points_range
    errors.add :min_points, 'minimum points must be less than maximum points'  if self.max_points && self.min_points && self.max_points < self.min_points
  end

  def points_in_range
    errors.add :points, 'must be between minimum points and maximum points' if self.min_points && self.max_points && ! (self.min_points..self.max_points).include?(self.points)
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
