require 'yaml'

class SystemDiskStatistics
  #attr_reader :exercise
  #delegate :submissions, to: :exercise

  def initialize
    location = YAML.load_file('config/system.yml')['db_location']
    @system_statistics = Hash.new
    df = `df #{location} -P`
    first_line = []
    df.each_line.with_index do |line, line_index|
      if line_index.eql? 0
        first_line = line.split
        next
      end
      line = line.split(' ')
      line.each.with_index do |token, token_index|
        @system_statistics[first_line[token_index].downcase] = token.to_i
      end
    end
  end

  def disk_used
    @system_statistics['used']
  end

  def disk_used_percentage
    @system_statistics['capacity']
  end

  def disk_available
    @system_statistics['available']
  end
end
