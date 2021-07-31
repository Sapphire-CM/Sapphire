class AddStatusToTerms < ActiveRecord::Migration[4.2]
  def change
    add_column :terms, :status, :integer, default: 0
  end
end
