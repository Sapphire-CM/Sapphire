# create_table :statistics, force: :cascade do |t|
#   t.integer  :exercise_id
#   t.integer  :sum
#   t.integer  :min
#   t.integer  :max
#   t.integer  :average
#   t.integer  :median
#   t.datetime :created_at,  null: false
#   t.datetime :updated_at,  null: false
#   t.boolean  :dirty_bit
# end
#
# add_index :statistics, [:exercise_id], name: :index_statistics_on_exercise_id
# 
# DELETE THIS MODEL
#

class Statistics < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :term

  def get_statistics
    if self.dirty_bit == nil || self.dirty_bit == true
      submissions = exercise.submissions.sort_by(&:filesystem_size)
      submission_file_size_max = submissions[submissions.length() - 1].filesystem_size
      submission_file_size_min = submissions[0].filesystem_size
      exercise_file_size = 0 
      if submissions.length() % 2 == 0 
        submission_file_size_median = (submissions[submissions.length() / 2].filesystem_size + submissions[submissions.length() / 2 - 1].filesystem_size) / 2 
      else
        submission_file_size_median = submissions[submissions.length() / 2 - 1].filesystem_size
      end
      submissions.each do |submission|
        exercise_file_size += submission.filesystem_size
      end
      self.sum = exercise_file_size 
      self.max = submission_file_size_max
      self.min = submission_file_size_min
      self.median = submission_file_size_median
      self.average = exercise_file_size / submissions.length()
      self.dirty_bit = false
    end
    {'sum' => self.sum, 'max' => self.max, 'min' => self.min, 'median' => self.median, 'average' => self.average} 
  end
end
