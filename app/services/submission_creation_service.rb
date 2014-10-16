class SubmissionCreationService
  def self.new_with_params(account, exercise, params)
    submission = Submission.new(params)
    submission.exercise = exercise
    SubmissionCreationService.new(account, submission)
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
    if result = @submission.save
      create_exercise_registrations!
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

    @model_setup = true
  end

  def model_setup?
    @model_setup
  end

  def create_exercise_registrations!
    if @submission.exercise.solitary_submission?
      term_registration = @account.term_registrations.students.find_by_term_id(@submission.exercise.term_id)
      raise ActiveRecord::RecordNotFound unless term_registration

      ExerciseRegistration.create!(submission: @submission, exercise: @submission.exercise, term_registration: term_registration)
    else
      # TODO: fetch group members and create exercise registrations for them as well
    end
  end
end
