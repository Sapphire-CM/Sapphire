class Evaluation < ActiveRecord::Base
  belongs_to :evaluation_group
  belongs_to :rating

  has_one :submission_evaluation, through: :evaluation_group
  has_one :student_group, through: :submission_evaluation
  has_one :submission, through: :submission_evaluation
  has_one :rating_group, through: :evaluation_group

  validate :validate_evaluation_type

  attr_accessible :rating_id, :type, :value

  after_create :update_result
  after_update :update_result, if: lambda {|eval| eval.value_changed? }

  scope :for_submission, lambda {|submission| joins{evaluation_group.submission_evaluation}.where{evaluation_group.submission_evaluation.submission_id == my{submission.id}}.readonly(false) }

  def self.create_for_evaluation_group(evaluation_group)
    evaluation_group.rating_group.ratings.each do |rating|
      evaluation = self.new_from_rating(rating)
      evaluation.evaluation_group = evaluation_group
      evaluation.save!
    end
  end


  private
  def self.new_from_rating(rating)
    ev = if rating.is_a? BinaryRating
      BinaryEvaluation.new
    elsif rating.is_a? ValueRating
      ValueEvaluation.new
    end

    unless ev.nil?
      ev.rating = rating
    end
    ev
  end

  def validate_evaluation_type
    errors[:type] = "must not be Evaluation" if self.type == "Evaluation"
  end

  def update_result
    self.evaluation_group.update_result!
  end
end
