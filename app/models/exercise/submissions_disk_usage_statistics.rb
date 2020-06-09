class Exercise::SubmissionsDiskUsageStatistics
  attr_reader :exercise
  delegate :submissions, to: :exercise

  def initialize(exercise)
    @exercise = exercise
  end

  def sum
    @sum ||= submissions.sum(:filesystem_size)
  end

  def average
    @average ||= submissions.average(:filesystem_size).to_i
  end

  def minimum
    @minimum ||= submissions.minimum(:filesystem_size)
  end

  def maximum
    @maximum ||= submissions.maximum(:filesystem_size)
  end

  def submissions_disk_usage
    @submissions_disk_usage ||= Exercise::SubmissionsDiskUsageStatistics.new(self)
  end
end
