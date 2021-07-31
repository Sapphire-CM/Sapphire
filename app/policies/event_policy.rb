class EventPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if admin?
        scope.all
      else
        events_scope = Event.joins(term: :term_registrations)

        staff_events = events_scope.merge(TermRegistration.staff.for_account(user))
        student_events_base = events_scope.merge(TermRegistration.students.for_account(user))

        student_events = student_events_base.where(type: submission_event_types, subject_id: Submission.for_account(user))
        .or(
          student_events_base.where(type: result_publication_event_types, subject_id: ResultPublication.for_account(user))
        )

        scope.where(id: staff_events.select(:id))
        .or(
          scope.where(id: student_events.select(:id))
        )
      end
    end

    private

    def submission_event_types
      [Events::Submission::Created, Events::Submission::Updated, Events::Submission::Extracted, Events::Submission::ExtractionFailed].map(&:to_s)
    end

    def result_publication_event_types
      [Events::ResultPublication::Published, Events::ResultPublication::Concealed]
    end
  end
end
