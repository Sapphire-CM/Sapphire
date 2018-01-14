class SubmissionBulk::Item
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :bulk, :subject_id, :subject, :submission
  attr_reader :evaluations

  delegate :exercise, :ratings, to: :bulk

  validates :subject_id, presence: true
  validate :validate_evaluations

  def self.new_with_submission(bulk, submission)
    new(bulk: bulk).tap do |item|
      item.build_new_evaluations!
      item.submission = submission
    end
  end

  def subject_id?
    subject_id.present?
  end

  def subject?
    subject.present?
  end

  def evaluations
    @evaluations ||= build_new_evaluations
  end

  def build_new_evaluations!
    @evaluations = build_new_evaluations
  end

  def build_new_evaluations
    ratings.map do |rating|
      ::SubmissionBulk::Evaluation.new({item: self, rating: rating})
    end
  end

  def evaluations_attributes=(evaluations_attributes)
    @evaluations = evaluations_attributes.map do |id, attributes|
      ::SubmissionBulk::Evaluation.new({item: self}.merge(attributes))
    end
  end

  def save
    ensure_submission!
  end

  def values?
    subject_id? || evaluations.any? { |evaluations| evaluations.value.present? }
  end

  private
  def ensure_submission!
    create_submission if submission.blank?
  end

  def create_submission
    raise NotImplemented
  end

  def validate_evaluations
    errors.add(:evaluations, :invalid) unless evaluations.map(&:valid?).all?
  end

  def update_item_values!
    existing_evaluations = submission.submission_evaluation.evaluations.where(rating_id: bulk.ratings).index_by(&:rating_id)

    evaluations.each do |evaluation|
      if existing_evaluation = existing_evaluations[evaluation.rating_id.to_i]
        evaluation.value = existing_evaluation.value
      end
    end
  end

  def extract_subject!
    @subject = if exercise.solitary_submission?
      submission.term_registrations.first
    else
      submission.student_group
    end
  end
end