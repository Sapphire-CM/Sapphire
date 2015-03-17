class ImportResult < ActiveRecord::Base
  belongs_to :import

  has_many :import_errors, dependent: :destroy

  validates :import, presence: true
  validates :import_id, uniqueness: true

  after_create :reset!

  def reset!
    self.update! success: false,
      total_rows: 0,
      processed_rows: 0,
      imported_students: 0,
      imported_tutorial_groups: 0,
      imported_term_registrations: 0,
      imported_student_groups: 0

    import_errors.destroy_all
  end

  def progress
    processed_rows.to_f / total_rows.to_f * 100.0
  end
end
