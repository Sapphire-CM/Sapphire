class MigrateAccountRegistrationsToTermRegistrations < ActiveRecord::Migration
  def up
    if self.class.const_defined?(:LecturerRegistration)
      LecturerRegistration.all.each do |lecturer_registration|
        TermRegistration.create!(account: lecturer_registration.lecturer, term: lecturer_registration.term, role: TermRegistration::LECTURER)
      end
    end

    if self.class.const_defined?(:TutorRegistration)
      TutorRegistration.all.each do |tutor_registration|
        TermRegistration.create!(account: tutor_registration.tutor, term: tutor_registration.term, tutorial_group: tutor_registration.tutorial_group, role: TermRegistration::TUTOR)
      end
    end

    if self.class.const_defined?(:StudentRegistration)
      StudentRegistration.all.each do |student_registration|
        term_reg = TermRegistration.where(account: student_registration.student, term: student_registration.term).first_or_create!( tutorial_group: student_registration.tutorial_group, role: TermRegistration::STUDENT)

        student_registration.student_group.submissions.each do |submission|
          ExerciseRegistration.create!(term_registration: term_reg, submission: submission, exercise: submission.exercise)
        end
      end
    end
  end

  def down
    if self.class.const_defined?(:LecturerRegistration)
      TermRegistration.lecturers.each do |term_registration|
        LecturerRegistration.where(lecturer: term_registration.account, term: term_registration.term).first_or_create!
      end
    end

    if self.class.const_defined?(:TutorRegistration)
      TermRegistration.tutors.each do |term_registration|
        TutorRegistration.where(tutor: term_registration.account, tutorial_group: term_registration.tutorial_group).first_or_create!
      end
    end

    if self.class.const_defined?(:StudentRegistration)
      TermRegistration.students.each do |term_registration|
        #TODO: Implement rollback of student registrations
      end
    end
  end
end
