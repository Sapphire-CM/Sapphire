require_relative "20141010144621_add_topic_identifier_to_student_group"
require_relative "20130913111450_add_points_to_student_groups"

class CleanupStudentGroups < ActiveRecord::Migration
  def change
    revert AddTopicIdentifierToStudentGroup
    revert AddPointsToStudentGroups
  end
end
