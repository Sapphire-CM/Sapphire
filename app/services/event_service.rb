class EventService
  attr_reader :term, :account

  def initialize(account, term)
    fail ArgumentError.new('No account specified') unless account.is_a?(Account)
    fail ArgumentError.new('No term specified') unless term.is_a?(Term)

    @account = account
    @term = term
  end

  def submission_created!(submission)
    Events::Submission::Created.create(submission_options(submission, true))
  end

  def submission_extracted!(submission, zip_submission_asset, extracted_submission_assets)
    Events::Submission::Extracted.create(submission_extracted_options(submission, zip_submission_asset, extracted_submission_assets))
  end

  def submission_asset_uploaded!(submission_asset)
    # not yet implemented
    submission = submission_asset.submission
    event = Events::Submission::Updated.where(account: account).recent_for_submission(submission)

    if event.blank?
      event = Events::Submission::Updated.new(options(submission, submission_base_options(submission)))
    end

    submission_assets = event.submission_assets || {
      added: [],
      updated: [],
      destroyed: []
    }

    description = submission_asset_description(submission_asset)

    if find_submission_asset_description(submission_assets[:destroyed], description)
      submission_assets[:updated] << description
      submission_assets[:destroyed].delete(description)
    elsif !find_submission_asset_description(submission_assets[:added], description)
      submission_assets[:added] << description
    end

    submission_assets.values.each do |assets|
      assets.sort_by! { |description|
        name = description[:name]
        path = description[:path]

        File.join(*([path, name].compact))
      }
    end

    event.submission_assets = submission_assets
    event.updated_at = Time.now
    event.save
    event
  end

  def submission_asset_destroyed!(submission_asset)
    # not yet implemented
    submission = submission_asset.submission
    submission = submission_asset.submission
    event = Events::Submission::Updated.where(account: account).recent_for_submission(submission)

    if event.blank?
      event = Events::Submission::Updated.new(options(submission, submission_base_options(submission)))
    end

    submission_assets = event.submission_assets || {
      added: [],
      updated: [],
      destroyed: []
    }

    description = submission_asset_description(submission_asset)

    if existing_description = find_submission_asset_description(submission_assets[:added], description)
      submission_assets[:added].delete(existing_description)
    elsif existing_description = find_submission_asset_description(submission_assets[:updated], description)
      submission_assets[:updated].delete(description)
      submission_assets[:destroyed] << description
    elsif !find_submission_asset_description(submission_assets[:destroyed], description)
      submission_assets[:destroyed] << description
    end

    event.submission_assets = submission_assets
    event.updated_at = Time.now
    event.save
    event
  end

  def submission_asset_extracted!(zip_asset, submission_assets)
    # not yet implemented
    event = nil
    submission_assets.each do |sa|
      event = submission_asset_uploaded!(sa)
    end
    event
  end

  def submission_assets_destroyed!(submission_assets)
    event = nil
    submission_assets.each do |sa|
      event = submission_asset_destroyed!(sa)
    end
    event
  end

  def submission_asset_extraction_failed!(submission_asset, failed_assets)
    submission = submission_asset.submission

    opts = {
      submission_asset: submission_asset_description(submission_asset),
      errors: failed_assets.map do |sa|
        {
          submission_asset: submission_asset_description(sa),
          messages: sa.errors.reject { |attribute, message| attribute == :filename }.map { |attribute, error| [sa.class.human_attribute_name(attribute), error].join(" ") }
        }
      end
    }

    Events::Submission::ExtractionFailed.create(options(submission, submission_base_options(submission, opts)))
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

  def comment_created!(comment)
    event = Events::Comment::Created.create(comment_options(comment))
    event.update(internal: comment_internal(comment))
    update_comment_event_subject(event, comment)
  end

  def comment_updated!(comment)
    event = Events::Comment::Updated.create(comment_options(comment))
    event.update(internal: comment_internal(comment))
    update_comment_event_subject(event, comment)
  end

  def comment_destroyed!(comment)
    event = Events::Comment::Destroyed.create(comment_options(comment))
    event.update(internal: comment_internal(comment))
    update_comment_event_subject(event, comment)
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
    options submission, submission_base_options(submission, submission_assets: submission_assets_changes(submission, new_record)).merge(attributes)
  end

  def submission_base_options(submission, attributes = {})
    {
      submission_id: submission.id,
      exercise_id: submission.exercise.id,
      exercise_title: submission.exercise.title,
    }.merge(attributes)
  end

  def comment_options(comment, attributes = {})
    options comment, {
      name: comment.name,
    }.merge(attributes)
  end

  def comment_internal(comment)
    !comment.name.in?(comments_shown_to_students)
  end

  def comments_shown_to_students
    ["feedback", "explanations"]
  end

  def update_comment_event_subject(event, comment)
    event.update(subject: comment.index_path)
  end

  def submission_asset_description(submission_asset)
    {
      file: File.basename(submission_asset.file.to_s),
      path: submission_asset.path,
      content_type: submission_asset.content_type
    }
  end

  def find_submission_asset_description(changes, description)
    changes.find do |change|
      change[:file] == description[:file] && change[:path] == description[:path]
    end
  end

  def submission_assets_changes(submission, new_record)
    submission_assets_changes = {
      added: [],
      updated: [],
      destroyed: []
    }

    submission.submission_assets.each do |sa|
      if sa.new_record? || new_record
        submission_assets_changes[:added] << submission_asset_description(sa)
      elsif sa.marked_for_destruction?
        submission_assets_changes[:destroyed] << submission_asset_description(sa)
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

  def submission_extracted_options(submission, zip_submission_asset, extracted_submission_assets)
    options submission, submission_base_options(submission).merge({
      zip_file: File.basename(zip_submission_asset.file.to_s),
      zip_path: zip_submission_asset.path,
      extracted_submission_assets: extracted_submission_assets.map { |submission_asset|
        {
          file: File.basename(submission_asset.file.to_s),
          path: submission_asset.path,
          content_type: submission_asset.content_type
        }
      }
    })
  end
end
