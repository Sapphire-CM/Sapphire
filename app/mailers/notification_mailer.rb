class NotificationMailer < ActionMailer::Base
  default from: "sapphire@sapphire.iicm.tugraz.at"

  def result_publication_notification(term_registration, result_publication)
    term_registration = term_registration
    result_publication = result_publication

    @exercise = result_publication.exercise
    @student = term_registration.account
    @term = term_registration.term

    mail(to: @student.email, subject: "[Sapphire] Results published for #{result_publication.exercise.title}")
  end
end
