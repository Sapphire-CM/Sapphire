class Evaluation < ActiveRecord::Base
  belongs_to :evaluation_group
  belongs_to :rating

  has_one :submission_evaluation, through: :evaluation_group
  has_one :student_group, through: :submission_evaluation
  has_one :submission, through: :submission_evaluation
  has_one :rating_group, through: :evaluation_group

  validate :validate_evaluation_type
  validates_presence_of :evaluation_group

  attr_accessible :rating_id, :type, :value

  after_create :update_result!, if: lambda {|eval| eval.value_changed?}
  after_update :update_result!, if: lambda {|eval| eval.value_changed? }
  after_destroy :update_result!

  scope :for_submission, lambda { |submission| joins{evaluation_group.submission_evaluation}.where{evaluation_group.submission_evaluation.submission_id == my{submission.id}}.readonly(false) }

  def self.create_for_evaluation_group(evaluation_group)
    evaluation_group.rating_group.ratings.each do |rating|
      evaluation = self.new_from_rating(rating)
      evaluation.evaluation_group = evaluation_group
      evaluation.save!
    end
  end

  def self.create_for_rating(rating)
    rating.rating_group.evaluation_groups.each do |eval_group|
      evaluation = self.new_from_rating(rating)
      evaluation.evaluation_group = eval_group
      evaluation.save!
    end
  end

  def points
    0
  end

  def percent
    1
  end

  def update_result!
    self.evaluation_group.update_result!
  end

  private
  def self.new_from_rating(rating)
    evaluation = rating.evaluation_class.new
    evaluation.rating = rating
    evaluation
  end

  def validate_evaluation_type
    errors[:type] = "must not be Evaluation" if self.type == "Evaluation"
  end

end
