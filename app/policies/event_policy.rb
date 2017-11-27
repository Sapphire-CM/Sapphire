class EventPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if admin?
        scope.all
      else
        scope.joins(term: :term_registrations).where do
          (
            term_registrations.id.in(my { TermRegistration.staff }) |
            (
              term_registrations.id.in(my { TermRegistration.students }) &
              (
                (events.type.in(my { submission_event_types }) & events.subject_id.in(my { Submission.for_account(user) })) |
                (events.type.in(my { result_publication_event_types }) & events.subject_id.in(
                  ResultPublication.where do
                    tutorial_group_id.in(my { my { user.tutorial_groups } })
                  end
                ))
              )
            )
          ) & (term_registrations.account_id == my { user.id })
        end
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
