class SubmissionCreationService
  def self.new_with_params(account, exercise, params)
    submission = Submission.new(params)
    submission.exercise = exercise
    SubmissionCreationService.new(account, submission)
  end

  def self.initialize_empty_submission(account, exercise)
    submission = Submission.new(exercise: exercise)
    service = SubmissionCreationService.new(account, submission)
    service.model
  end

  def initialize(account, submission)
    @account = account
    @submission = submission
    @model_setup = false
  end

  def model
    ensure_model_setup!
    @submission
  end

  def valid?
    ensure_model_setup!
    @submission.valid?
  end

  def save
    ensure_model_setup!

    result = false
    ActiveRecord::Base.transaction do
      if result = @submission.save
        create_event!
        create_exercise_registrations!
      end
    end

    result
  end

  private

  def ensure_model_setup!
    setup_model! unless model_setup?
  end

  def setup_model!
    @submission.submitter = @account
    @submission.submitted_at = Time.now
    @submission.student_group = term_registration.student_group unless @submission.exercise.solitary_submission?

    build_exercise_registrations!

    @model_setup = true
  end

  def model_setup?
    @model_setup
  end

  def term_registration
    @term_registration ||= @account.term_registrations.students.find_by!(term_id: @submission.exercise.term_id)
  end

  def build_exercise_registrations!
    if @submission.exercise.solitary_submission? || term_registration.student_group.blank?
      @submission.exercise_registrations.build(exercise: @submission.exercise, term_registration: term_registration)
    else
      student_group = term_registration.student_group
      student_group.term_registrations.each do |term_registration|
        @submission.exercise_registrations.build(exercise: @submission.exercise, term_registration: term_registration)
      end
    end
  end

  def create_exercise_registrations!
    build_exercise_registrations!
  end

  def create_event!
    event_service = EventService.new(@account, @submission.exercise.term)
    event_service.submission_created!(@submission)
  end
end
