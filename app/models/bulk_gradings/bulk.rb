class BulkGradings::Bulk
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :exercise, :account
  attr_writer :items, :exercise_attempt, :exercise_attempt_id

  delegate :group_submission?, :solitary_submission?, to: :exercise
  delegate :id, to: :exercise_attempt, prefix: true

  validate :validate_items
  validates :exercise_attempt_id, presence: true, if: :multiple_attempts?
  validates :exercise_attempt_id, absence: true, unless: :multiple_attempts?

  def items_attributes=(item_attributes)
    @items = item_attributes.map do |id, attributes|
      BulkGradings::Item.new({bulk: self}.merge(attributes))
    end

    set_missing_subjects!
  end

  def exercise_attempt_id
    @exercise_attempt_id ||= @exercise_attempt.try(:id)
  end

  def exercise_attempt
    if @exercise_attempt_id.present?
      @exercise_attempt = exercise.attempts.find(@exercise_attempt_id)
      @exercise_attempt_id = nil
    end

    @exercise_attempt
  end

  def multiple_attempts?
    exercise.enable_multiple_attempts? if exercise
  end

  def ratings
    @ratings ||= @exercise.ratings.bulk.to_a
  end

  def rating_with_id(id)
    id = id.to_i
    ratings.find { |rating| rating.id == id }
  end

  def items
    @items ||= []
  end

  def ensure_blank!
    items << blank_item if items.length == 0 || items.last.try(:values?)
  end

  def blank_item
    BulkGradings::Item.new({bulk: self})
  end

  def save
    raise ::BulkGradings::BulkNotValid unless valid?

    set_existing_submissions!
    filled_items.each(&:save)
  end

  private
  def set_missing_subjects!
    items_missing_subjects = items.select { |item| item.subject_id? && !item.subject? }

    subjects = subjects_finder.find(items_missing_subjects.map(&:subject_id)).index_by(&:id)

    items_missing_subjects.each do |item|
      item.subject = subjects[item.subject_id.to_i] if subjects.key?(item.subject_id.to_i)
    end
  end

  def set_existing_submissions!
    submissions = submission_finder.find_submissions_for_subjects(items.map(&:subject))

    items.each do |item|
      item.submission = submissions[item.subject] if submissions.key?(item.subject)
    end
  end

  def filled_items
    items.keep_if(&:values?)
  end

  def subjects_finder
    BulkGradings::SubjectsFinder.new(exercise: exercise)
  end

  def submission_finder
    BulkGradings::SubmissionsFinder.new(exercise: exercise, exercise_attempt: exercise_attempt)
  end

  def validate_items
    errors.add(:items, :invalid) unless filled_items.map(&:valid?).all?
  end
end