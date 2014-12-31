class NotificationMailer < ActionMailer::Base
  default from: 'sapphire@sapphire.iicm.tugraz.at'
  helper :layout

  def result_publication_notification(term_registration, result_publication)
    term_registration = term_registration
    result_publication = result_publication

    @exercise = result_publication.exercise
    @student = term_registration.account
    @term = term_registration.term

    mail(to: @student.email, subject: "[Sapphire] Results published for #{result_publication.exercise.title}")
  end

  def export_finished_notification(recipient, export)
    @export = export
    @term = export.term
    @course = @term.course
    @recipient = recipient

    mail(to: recipient.email, subject: "[Sapphire] Export finished: #{course_term_title(term)}")
  end

  def welcome_notification(account, term)
    @account = account

    mail(to: account.email, subject: "[Sapphire] Welcome - #{course_term_title(term)}")
  end

  def welcome_back_notification(account, term)
    @account = account
    @term = term

    mail(to: account.email, subject: "[Sapphire] Welcome Back - #{course_term_title(term)}")
  end

  private

  def course_term_title(term)
    "#{term.course.title}: #{term.title}"
  end
end
