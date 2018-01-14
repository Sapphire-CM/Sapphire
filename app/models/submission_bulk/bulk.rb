class SubmissionBulk::Bulk
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :exercise

  delegate :group_submission?, :solitary_submission?, to: :exercise

  validates :items, length: { minimum: 1 }
  validate :validate_items

  def items_attributes=(item_attributes)
    @items = item_attributes.map do |id, attributes|
      ::SubmissionBulk::Item.new({bulk: self}.merge(attributes))
    end

    set_missing_subjects!
  end

  def ratings
    @ratings ||= @exercise.ratings.bulk.to_a
  end

  def items
    @items ||= []
  end

  def ensure_blank!
    items << blank_item if items.length == 0 || items.last.try(:values?)
  end

  def blank_item
    SubmissionBulk::Item.new({bulk: self})
  end

  def save
    raise BulkNotValid unless valid?

    set_existing_submissions!
    items.each(&:save)
  end

  private
  def set_missing_subjects!
    items_missing_subjects = @items.select { |item| item.subject_id? && !item.subject? }

    subjects = subjects_finder.find(items_missing_subjects.map(&:subject_id)).index_by(&:id)

    items_missing_subjects.each do |item|
      item.subject = subjects[item.subject_id.to_i]
    end
  end

  def set_existing_submissions!
    submissions = submission_finder.find_submissions_for_subjects(items.map(&:subject))
    items.each do |item|
      item.submission = submissions[item.subject]
    end
  end

  def subjects_finder
    SubmissionBulks::SubjectsFinder.new(exercise: exercise)
  end

  def submission_finder
    SubmissionBulks::SubmissionsFinder.new(exercise: exercise)
  end

  def validate_items
    errors.add(:items, :invalid) unless items.reject { |item| !item.values? }.map(&:valid?).all?
  end
end