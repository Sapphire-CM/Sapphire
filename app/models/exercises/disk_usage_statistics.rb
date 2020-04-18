module Exercises::DiskUsageStatistics
    def get_disk_usage_sum
      submissions.sum(:filesystem_size)
    end

    def get_disk_usage_average
      submissions.average(:filesystem_size)
    end

    def get_disk_usage_minimum
      submissions.minimum(:filesystem_size)
    end

    def get_disk_usage_maximum
      submissions.maximum(:filesystem_size)
    end
end
