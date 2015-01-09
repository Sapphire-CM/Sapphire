class ChangeAccountAdminDefault < ActiveRecord::Migration
  def up
    change_column :accounts, :admin, :boolean, default: false
  end

  def down
    change_column :accounts, :admin, :boolean
  end
end
