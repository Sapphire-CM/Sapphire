# create_table :exercise_attempts, force: :cascade do |t|
#   t.integer  :exercise_id
#   t.string   :title
#   t.datetime :date
#   t.datetime :created_at,  null: false
#   t.datetime :updated_at,  null: false
#   t.index [:exercise_id], name: :index_exercise_attempts_on_exercise_id
# end

class ExerciseAttempt < ActiveRecord::Base
  belongs_to :exercise, inverse_of: :attempts

  has_many :submissions, dependent: :nullify

  validates :exercise, presence: true
  validates :title, presence: true, uniqueness: { scope: :exercise_id }

  scope :default, lambda { where(default: true) }
end
