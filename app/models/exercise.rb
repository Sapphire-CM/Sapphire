class Exercise < ActiveRecord::Base
  include RankedModel

  belongs_to :term

  ranks :row_order, with_same: :term_id

  delegate :course, to: :term

  default_scope { rank(:row_order) }
  scope :for_evaluations_table, lambda { includes(submissions: [{submission_evaluation: {evaluation_groups: [:rating_group, {evaluations: :rating}]}}, {student_group_registration: {student_group: :students}}])}

  scope :group_exercises, lambda { where(group_submission: true)}
  scope :solitary_exercises, lambda { where(group_submission: false)}

  has_many :result_publications, dependent: :destroy
  has_many :student_group_registrations, dependent: :destroy
  has_many :student_groups, through: :student_group_registrations
  has_many :submissions
  has_many :submission_evaluations, through: :submissions
  has_many :rating_groups, dependent: :destroy
  has_many :ratings, through: :rating_groups
  has_many :services


  before_save :update_points, if: lambda { |exercise| exercise.enable_max_total_points_changed? || exercise.max_total_points_changed? }
  after_create :ensure_result_publications
  after_save :update_term_points, if: :points_changed?
  after_save :recalculate_term_registrations_results, if: lambda {|exercise| exercise.enable_min_required_points_changed? || exercise.min_required_points_changed? || exercise.points_changed?}

  validates_presence_of :title
  validates_presence_of :min_required_points, if: Proc.new { enable_min_required_points }
  validates_presence_of :max_total_points, if: Proc.new { enable_max_total_points }
  validates_presence_of :maximum_upload_size, if: Proc.new { enable_max_upload_size }

  def update_points
    self.points = self.reload.rating_groups.map {|rg| rg.max_points || rg.points}.compact.sum || 0
    self.points = max_total_points if enable_max_total_points && points > max_total_points
  end

  def update_points!
    update_points
    self.save!
  end

  def submission_viewer?
    submission_viewer_identifier.present?
  end

  def update_term_points
    term.update_points!
  end

  def result_publication_for(tutorial_group)
    ResultPublication.for(exercise: self, tutorial_group: tutorial_group)
  end

  def result_published_for?(tutorial_group)
    result_publication_for(tutorial_group).published?
  end

  def solitary_submission?
    !group_submission?
  end

  def recalculate_term_registrations_results
    TermRegistrationsPointsUpdateWorker.perform_async(term.id)
  end

  def ensure_services
    Service.service_classes.each do |service_class|
      unless self.services.find { |s| s.is_a? service_class }
        service_class.create(exercise: self)
      end
    end
  end

  private
  def ensure_result_publications
    term.tutorial_groups.each do |tutorial_group|
      ResultPublication.find_or_create_by(exercise: self, tutorial_group: tutorial_group)
    end
  end
end
