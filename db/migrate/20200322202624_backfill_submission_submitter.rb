class BackfillSubmissionSubmitter < ActiveRecord::Migration
  def change
    Submission.where(submitter_id:nil).each do |sub|
      if sub.students.empty?
        sub.destroy
      else
        sub.update(submitter_id: sub.students.first.id)
      end
    end
  end
end
