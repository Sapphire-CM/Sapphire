class RatingGroup < ActiveRecord::Base
  belongs_to :exercise
  has_many :ratings, :dependent => :destroy

  validates_presence_of :title
  validates_presence_of :points, :unless => Proc.new do |rating_group|
    rating_group.global == true
  end

  attr_accessible :title, :description, :points, :exercise, :global

  # global: true     if there is no maximum points for this group, therefore all
  #                  ratings count directly to the whole exercise
  #         false    if the ratings only can substract from the specified maximum
  #                  points for this rating_group.
  #         example  Plagiarism:         -50%
  #                  late deadline:      -50%
  #                  misc. subtractions: -42 points
  #                  misc. bonus:        +21 points

end
