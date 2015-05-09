class EventPolicy < PunditBasePolicy
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(term: :term_registrations).where do
          (
            term_registrations.id.in(my { TermRegistration.staff }) |
            (
              term_registrations.id.in(my { TermRegistration.students }) &
              (
                events.type.in(my { submission_event_types }) &
                (
                  events.subject_id.in( my { Submission.for_account(user) } )
                )
              )
            )
          ) & (term_registrations.account_id == my {user.id})
        end
      end
    end

    private
    def submission_event_types
      [Events::Submission::Created, Events::Submission::Updated].map(&:to_s)
    end

  end
end
