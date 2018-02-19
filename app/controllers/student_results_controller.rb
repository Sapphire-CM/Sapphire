class StudentResultsController < ApplicationController
  include TermContext

  def index
    authorize StudentResultsPolicy.term_policy_record(current_term)

    @term_review = GradingReview::TermReview.find_with_term_and_account(current_term, current_account)
  end

  def show
    set_exercise

    @submission_review = GradingReview::SubmissionReview.find_by_account_and_exercise(current_account, @exercise)

    authorize StudentResultsPolicy.policy_record_with(submission_review: @submission_review)
  end

  private
  def set_exercise
    @exercise = current_term.exercises.find(params[:id])
  end
end
