class Course < ActiveRecord::Base
  has_many :terms, dependent: :destroy

  validates_presence_of :title
  validates_uniqueness_of :title

  scope :unlocked, lambda { where(locked: false) }

  def self.associated_with(account)
    joins(:terms).where(terms: {id: Term.associated_with(account).pluck(:id)}).uniq
  end

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
    Course.associated_with(account).where(id: self.id).exists?
  end
end
