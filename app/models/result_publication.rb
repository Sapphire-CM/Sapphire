# create_table :result_publications, force: :cascade do |t|
#   t.integer  :exercise_id
#   t.integer  :tutorial_group_id
#   t.boolean  :published,         default: false, null: false
#   t.datetime :created_at,                        null: false
#   t.datetime :updated_at,                        null: false
# end
#
# add_index :result_publications, [:exercise_id, :tutorial_group_id], name: :index_result_publications_on_exercise_id_and_tutorial_group_id, unique: true, using: :btree
# add_index :result_publications, [:exercise_id], name: :index_result_publications_on_exercise_id, using: :btree
# add_index :result_publications, [:tutorial_group_id], name: :index_result_publications_on_tutorial_group_id, using: :btree

class ResultPublication < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :tutorial_group

  has_one :term, through: :exercise

  scope :published, lambda { where(published: true) }
  scope :concealed, lambda { where(published: false) }

  validates :exercise, presence: true
  validates :exercise_id, uniqueness: { scope: :tutorial_group_id }
  validates :tutorial_group, presence: true

  def self.for(exercise: nil, tutorial_group: nil)
    find_by(exercise_id: exercise.id, tutorial_group_id: tutorial_group.id)
  end

  def concealed?
    !published?
  end

  def publish!
    self.published = true
    self.save!
  end

  def conceal!
    self.published = false
    self.save!
  end
end
