class GradingReviewsController < ApplicationController
  include TermContext

  def index
    authorize GradingReview::TermReviewPolicy.term_policy_record current_term

    @term_registrations = current_term.term_registrations.students.search(params[:q]).load if params[:q].present?
  end

  def show
    set_term_review
  end

  private
  def set_term_review
    @term_review = GradingReview::TermReview.find_with_term_and_term_registration_id(current_term, params[:id])

    authorize @term_review
  end
end
