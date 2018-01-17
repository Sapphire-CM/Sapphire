module SubmissionBulksHelper
  def submission_bulk_subject(subject)
    case subject
    when TermRegistration
      account = subject.account
      subline = [].tap do |parts|
        parts << account.matriculation_number
        parts << subject.tutorial_group.title if subject.tutorial_group.present?
      end.join(" - ")


      content_tag(:strong, account.fullname) + tag(:br) + content_tag(:span, subline)
    when StudentGroup
      content_tag(:strong, subject.title)
    else
      content_tag(:em, "Undefined subject")
    end
  end

  def submission_bulk_evaluation_input(f)
    evaluation = f.object
    case evaluation.rating
    when Ratings::FixedRating
      f.input(:value, label: false, as: :boolean)
    when Ratings::VariableRating
      f.input(:value, label: false)
    else
      "Unknown rating type"
    end
  end
end
