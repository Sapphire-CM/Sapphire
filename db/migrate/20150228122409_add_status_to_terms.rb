class AddStatusToTerms < ActiveRecord::Migration
  def change
    add_column :terms, :status, :integer, default: 0
  end
end
