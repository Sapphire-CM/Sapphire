class SubmissionEvaluation < ActiveRecord::Base
  belongs_to :submission
  belongs_to :evaluator, polymorphic: true
  
  attr_accessible :evaluations_attributes
  
  has_many :evaluations, dependent: :destroy
  has_many :ratings, through: :evaluations
  has_many :rating_groups, through: :ratings
  
  accepts_nested_attributes_for :evaluations
  
  validates_uniqueness_of :submission_id
  validates_presence_of :evaluated_at
  
  before_save :update_evaluation_result
    
  def prepared_evaluations
    needed_ratings = submission.exercise.ratings
    evals = self.evaluations
    needed_ratings.where(:id => (needed_ratings.map(&:id) - evaluations.pluck(:rating_id))).all.each do |rating|
      evals << rating.build_evaluation
    end
    evals
  end

  
  def update_evaluation_result!
    self.evaluation_result = calc_evaluation_result
    self.save!
  end
  
  def update_evaluation_result
    self.evaluation_result = calc_evaluation_result
  end
  
  def calc_evaluation_result
    final_sum = 0
    percent = 100
    self.evaluations.joins(rating: :rating_group).includes(rating: :rating_group).group_by { |ev| ev.rating_group}.each do |rating_group, evaluations|
      group_sum = rating_group.points
      evaluations.each do |evaluation|
        rating = evaluation.rating
        if evaluation.is_a? BinaryEvaluation
          if evaluation.value == 1
            if rating.is_a? BinaryNumberRating
              group_sum += rating.value
            elsif rating.is_a? BinaryPercentRating
              percent += rating.value
            end
          end
        else
          if rating.is_a? ValueNumberRating
            group_sum += evaluation.value
          elsif rating.is_a? ValuePercentRating
            percent += evaluation.value
          end
        end
      end
      
      group_sum = 0 if group_sum < 0
      
      final_sum += group_sum
    end
        
    final_sum = final_sum.to_f * (percent.to_f/100.0)
    final_sum = 0 if final_sum < 0
    
    final_sum
  end
  
  
end
