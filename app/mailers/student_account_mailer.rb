class StudentAccountMailer < ActionMailer::Base
  default from: "sapphire@sapphire.iicm.tugraz.at"

  def account_notification(student, student_group)
    @student = student
    @student_group = student_group

    mail(to: @student.email, subject: "[Sapphire] Welcome to #{@student_group.term.course.title}: #{@student_group.term.title}")
  end
end
