# create_table :import_results, force: :cascade do |t|
#   t.integer  :import_id
#   t.boolean  :success,                     default: false, null: false
#   t.boolean  :encoding_error,              default: false, null: false
#   t.boolean  :parsing_error,               default: false, null: false
#   t.integer  :total_rows
#   t.integer  :processed_rows
#   t.integer  :imported_students
#   t.integer  :imported_tutorial_groups
#   t.integer  :imported_term_registrations
#   t.integer  :imported_student_groups
#   t.datetime :created_at,                                  null: false
#   t.datetime :updated_at,                                  null: false
#   t.index [:import_id], name: :index_import_results_on_import_id, unique: true
# end

class ImportResult < ActiveRecord::Base
  belongs_to :import

  has_many :import_errors, dependent: :destroy

  validates :import, presence: true
  validates :import_id, uniqueness: true

  validates :processed_rows, :total_rows, numericality: { greater_than_or_equal_to: 0 }

  after_create :reset!
  after_initialize :set_default_options!, if: :new_record?

  def reset!
    set_default_options!
    save!
    import_errors.destroy_all
  end

  def progress
    if total_rows == 0
      0
    else
      processed_rows.to_f / total_rows.to_f * 100.0
    end
  end

  private
  def set_default_options!
    default_options = {
      success: false,
      total_rows: 0,
      processed_rows: 0,
      imported_students: 0,
      imported_tutorial_groups: 0,
      imported_term_registrations: 0,
      imported_student_groups: 0
    }

    self.assign_attributes(default_options)
  end
end
