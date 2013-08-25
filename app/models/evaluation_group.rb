class EvaluationGroup < ActiveRecord::Base
  belongs_to :rating_group
  belongs_to :submission_evaluation

  after_create :create_evaluations
  has_many :evaluations, dependent: :destroy

  after_save :update_submission_evaluation_results, if: lambda {|eg| eg.points_changed? || eg.percent_changed?}

  def self.create_for_submission_evaluation(submission_evaluation)
    submission_evaluation.submission.exercise.rating_groups.each do |rating_group|
      eg = self.new
      eg.rating_group = rating_group
      eg.points = rating_group.points
      eg.submission_evaluation = submission_evaluation
      eg.save!
    end
  end

  def update_result!
    self.calc_result
    self.save!
  end

  def calc_result
    points_sum = rating_group.points
    percent_product = 1

    self.evaluations.includes(:rating).uniq.each do |evaluation|
      rating = evaluation.rating

      # TODO: refactor this into Evaluation itself!
      if evaluation.is_a? BinaryEvaluation
        if evaluation.value == 1
          if rating.is_a? BinaryNumberRating
            points_sum += rating.value
          elsif rating.is_a? BinaryPercentRating
            percent_product *= 1 + rating.value.to_f/100.0
          end
        end
      else
        if rating.is_a? ValueNumberRating
          points_sum += evaluation.value
        elsif rating.is_a? ValuePercentRating
          percent_product *= 1 + evaluation.value.to_f/100.0
        end
      end
    end

    if points_sum < (min_points = self.rating_group.min_points || 0)
      points_sum = min_points
    elsif points > (max_points = self.rating_group.max_points || rating_group.points || 0)
      points_sum = max_points
    end


    self.points = points_sum
    self.percent = percent_product
    true
  end

  private

  def update_submission_evaluation_results
    self.submission_evaluation.calc_results!
  end

  def create_evaluations
    Evaluation.create_for_evaluation_group(self)
  end
end
