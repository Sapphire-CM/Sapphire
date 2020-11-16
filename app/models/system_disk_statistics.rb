class SystemDiskStatistics

  def disk_used
    system_statistics['used']
  end

  def disk_used_percentage
    system_statistics['capacity']
  end

  def disk_available
    system_statistics['available']
  end

  private

  def system_statistics
    @system_statistics ||= fetch_system_statistics
  end

  def fetch_system_statistics
    location = Rails.configuration.system['db_location']
    system_statistics_ = Hash.new
    df = `df #{location} -P`
    first_line = []
    df.each_line.with_index do |line, line_index|
      if line_index.eql? 0
        first_line = line.split
        next
      end
      line = line.split(' ')
      line.each.with_index do |token, token_index|
        system_statistics_[first_line[token_index].downcase] = token.to_i
      end
    end
    return system_statistics_
  end
end
