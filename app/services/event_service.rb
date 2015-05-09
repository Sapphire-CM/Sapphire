class EventService
  attr_reader :term, :account

  def initialize(account, term)
    raise ArgumentError.new("No term specified") unless term.present?

    @account = account
    @term = term
  end

  def submission_updated!(term, account, submission)
    Events::Submission::Updated.create(options_with_data(subject: submission))
  end

  def submission_created!(term, account, submission)
    data = {
      submission_id: submission.id,
      exercise_id: submission.exercise.id,
      exercise_title: submission.exercise.title,
      files: submission.submission_assets.map {|sa| File.join(sa.path, File.basename(sa.file.to_s)) }
    }

    Events::Submission::Created.create(options(submission, data))
  end

  def rating_created!(rating)
    Events::Rating::Created.create(rating_options(rating))
  end

  def rating_updated!(rating)
    Events::Rating::Updated.create(rating_options(rating, changes: rating.changes))
  end

  def rating_destroyed!(rating)
    Events::Rating::Destroyed.create(rating_options(rating))
  end

  def rating_group_created!(rating_group)
    Events::RatingGroup::Created.create(rating_group_options(rating_group))
  end

  def rating_group_updated!(rating_group)
    Events::RatingGroup::Updated.create(rating_group_options(rating_group, changes: rating_group.changes))
  end

  def rating_group_destroyed!(rating_group)
    Events::RatingGroup::Destroyed.create(rating_group_options(rating_group))
  end

  private
  def options(subject, data = {})
    default_options.merge(subject: subject, data: data)
  end

  def default_options
    {term: term, account: account}
  end

  def rating_options(rating, attributes = {})
    options rating, {
      rating_title: rating.title,
      rating_id: rating.id,
      rating_group_title: rating.rating_group.title,
      rating_group_id: rating.rating_group.id,
      exercise_title: rating.exercise.title,
      exercise_id: rating.exercise.id,
      value: rating.value
    }.merge(attributes)
  end

  def rating_group_options(rating_group, attributes = {})
    options rating_group, {
      rating_group_title: rating_group.title,
      rating_group_id: rating_group.id,
      exercise_title: rating_group.exercise.title,
      exercise_id: rating_group.exercise.id,
      points: rating_group.points
    }.merge(attributes)
  end
end
