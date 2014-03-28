class StudentResultsPolicy < PunditBasePolicy
  def show?
    user.admin? ||
    (record.submission.present? ? record.submission.result_published? : false)
  end
end
