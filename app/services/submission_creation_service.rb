class SubmissionCreationService
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :exercise, :creator, :on_behalf_of, :exercise_attempt

  validates :exercise, :creator, presence: true
  validate :validate_submission
  validate :creator_is_account

  delegate :group_submission?, to: :exercise

  class ReceiverInvalidError < StandardError; end

  def self.new_student_submission(account, exercise)
    SubmissionCreationService.new({creator: account, exercise: exercise})
  end

  def self.new_staff_submission(staff_account, receiver, exercise)
    SubmissionCreationService.new({creator: staff_account, exercise: exercise, on_behalf_of: receiver})
  end

  def submission
    @submission ||= build_submission
  end

  def save
    result = false

    ActiveRecord::Base.transaction do
      if result = submission.save
        create_event!
      end
    end

    result
  end

  private
  def build_submission
    Submission.new(exercise: exercise, submitter: creator, submitted_at: Time.zone.now, exercise_attempt: exercise_attempt).tap do |submission|
      submission.student_group = receiver_student_group if group_submission?

      build_exercise_registrations(submission)
    end
  end

  def term
    exercise.term
  end

  def receiver
    on_behalf_of || creator
  end

  def receiver_term_registrations
    if group_submission?
      case receiver
      when Account then term_registration_for_receiver.student_group.term_registrations
      when TermRegistration then receiver.student_group.term_registrations
      when StudentGroup then receiver.term_registrations
      else
        raise ReceiverInvalidError
      end
    else
      case receiver
      when Account then [term_registration_for_receiver]
      when TermRegistration then [receiver]
      else
        raise ReceiverInvalidError
      end
    end
  end

  def receiver_student_group
    case receiver
    when StudentGroup then receiver
    when TermRegistration then receiver.student_group
    when Account then term_registration_for_receiver.student_group
    end
  end

  def term_registration_for_receiver
    receiver.term_registrations.find_by!(term: exercise.term)
  end

  def build_exercise_registrations(submission)
    exercise_registrations_attributes = receiver_term_registrations.map do |term_registration|
      {term_registration: term_registration, exercise: exercise}
    end

    submission.exercise_registrations.build(exercise_registrations_attributes)
  end

  def create_event!
    event_service = EventService.new(creator, term)
    event_service.submission_created!(submission)
  end

  def validate_submission
    errors.add(:submission, :invalid) unless submission.valid?
  end

  def creator_is_account
    errors.add(:creator, "is not an Account") unless creator.is_a?(Account)
  end
end
