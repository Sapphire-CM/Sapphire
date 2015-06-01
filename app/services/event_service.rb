class EventService
  attr_reader :term, :account

  def initialize(account, term)
    fail ArgumentError.new('No term specified') unless term.present?

    @account = account
    @term = term
  end

  def submission_updated!(submission)
    Events::Submission::Updated.create(submission_options(submission, false))
  end

  def submission_created!(submission)
    Events::Submission::Created.create(submission_options(submission, true))
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

  def result_publication_published!(result_publication)
    Events::ResultPublication::Published.create(result_publication_options(result_publication))
  end

  def result_publication_concealed!(result_publication)
    Events::ResultPublication::Concealed.create(result_publication_options(result_publication))
  end

  private
  def options(subject, data = {})
    default_options.merge(subject: subject, data: data)
  end

  def default_options
    {term: term, account: account}
  end

  def result_publication_options(result_publication)
    options result_publication, {
      exercise_id: result_publication.exercise.id,
      exercise_title: result_publication.exercise.title,
      tutorial_group_id: result_publication.tutorial_group.id,
      tutorial_group_title: result_publication.tutorial_group.title
    }
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

  def submission_options(submission, new_record, attributes = {})
    options submission, {
      submission_id: submission.id,
      exercise_id: submission.exercise.id,
      exercise_title: submission.exercise.title,
      submission_assets: submission_assets_changes(submission, new_record)
    }.merge(attributes)
  end

  def submission_assets_changes(submission, new_record)
    submission_assets_changes = {
      added: [],
      updated: [],
      destroyed: []
    }

    submission.submission_assets.each do |sa|
      submission_asset_description = lambda do
        {
          file: File.basename(sa.file.to_s),
          path: sa.path,
          content_type: sa.content_type
        }
      end

      if sa.new_record? || new_record
        submission_assets_changes[:added] << submission_asset_description.call
      elsif sa.marked_for_destruction?
        submission_assets_changes[:destroyed] << submission_asset_description.call
      elsif sa.changed?
        if sa.changes.key? 'file'
          submission_assets_changes[:updated] << {
            file: sa.changes['file'].map { |file| File.basename(file.to_s) },
            path: sa.path,
            content_type: sa.content_type
          }
        end
      end
    end

    submission_assets_changes
  end
end
