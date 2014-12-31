class WelcomeMailer < ActionMailer::Base
  default from: "sapphire@sapphire.iicm.tugraz.at"

  helper :layout

  def welcome_notification(account, term)
    @account = account
    mail(to: account.email, subject: "Welcome to Sapphire (#{course_term_title(term)})")
  end

  def welcome_back_notification(account, term)
    @account = account
    @term = term
    mail(to: account.email, subject: "Welcome Back to Sapphire (#{course_term_title(term)})")
  end


  private
  def course_term_title(term)
    "#{term.course.title}: #{term.title}"
  end
end
