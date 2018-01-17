# create_table :courses, force: :cascade do |t|
#   t.string   :title
#   t.text     :description
#   t.datetime :created_at,                 null: false
#   t.datetime :updated_at,                 null: false
#   t.boolean  :locked,      default: true, null: false
# end
#
# add_index :courses, [:title], name: :index_courses_on_title, unique: true

class Course < ActiveRecord::Base
  has_many :terms, dependent: :destroy

  validates :title, presence: true, uniqueness: true

  scope :unlocked, lambda { where(locked: false) }
  scope :associated_with, lambda { |account| joins(terms: :term_registrations).where(term_registrations: { account_id: account.id }).uniq }

  def unlocked?
    !locked?
  end

  def self.viewable_for(account)
    if account.admin?
      all
    else
      associated_with(account)
    end
  end

  def associated_with?(account)
    Course.associated_with(account).exists?(id: id)
  end
end
