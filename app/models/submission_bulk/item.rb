class SubmissionBulk::Item
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :bulk, :subject_id, :subject, :submission

  delegate :exercise, :exercise_attempt, :multiple_attempts?, :ratings, :account, to: :bulk

  validates :subject_id, presence: true
  validate :validate_subject_uniqueness
  validate :validate_evaluations

  def subject_id?
    subject_id.present?
  end

  def subject?
    subject.present?
  end

  def submission?
    submission.present?
  end

  def evaluations
    @evaluations ||= build_new_evaluations
  end

  def evaluation_for_rating(rating)
    evaluations_of_submission.find_by(rating: rating)
  end

  def evaluations_attributes=(evaluations_attributes)
    @evaluations = evaluations_attributes.map do |id, attributes|
      ::SubmissionBulk::Evaluation.new({item: self}.merge(attributes))
    end
  end

  def save
    ActiveRecord::Base.transaction do
      ensure_submission!

      evaluations.each(&:save)

      submission.submission_evaluation.update(evaluated_at: Time.zone.now, evaluator: account)
      submission.mark_as_recent! unless submission.recent?
    end
  end

  def values?
    subject_id? || evaluations.any? { |evaluations| evaluations.value? }
  end

  private
  def evaluations_of_submission
    @evaluations_of_submission ||= submission.submission_evaluation.evaluations.includes(rating: :rating_group)
  end

  def build_new_evaluations
    ratings.map do |rating|
      ::SubmissionBulk::Evaluation.new({item: self, rating: rating})
    end
  end

  def ensure_submission!
    unless submission?
      @submission = create_submission
    end
  end

  def create_submission
    service = SubmissionCreationService.new_staff_submission(account, subject, exercise)
    service.exercise_attempt = exercise_attempt if multiple_attempts?
    raise ::SubmissionBulk::BulkNotValid unless service.save
    service.submission
  end

  def validate_evaluations
    errors.add(:evaluations, :invalid) unless evaluations.map(&:valid?).all?
  end

  def validate_subject_uniqueness
    if bulk.items.any? { |item| item != self && item.subject == subject}
      errors.add(:subject, :taken)
      errors.add(:subject_id, :taken)
    end
  end
end