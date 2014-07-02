class StudentResultsPolicy < PunditBasePolicy
  def index?
    user.admin? ||
    begin
      record.submission.map do |sub|
        sub.student_group.present? &&
        sub.student_group.students.include?(user)
      end.all?
    end
  end

  def show?
    user.admin? ||
    (record.submission.present? ? record.submission.result_published? : false)
  end
end
