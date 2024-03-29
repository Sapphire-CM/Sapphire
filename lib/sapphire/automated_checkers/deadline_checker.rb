module Sapphire
  module AutomatedCheckers
    class DeadlineChecker < Base
      checks_assets!

      check :submitted_late, 'An asset has been submitted after the deadline' do
        date = subject.submitted_at || subject.created_at

        if exercise.deadline < date && date < exercise.late_deadline
          failed!
        else
          success!
        end
      end
    end
  end
end
