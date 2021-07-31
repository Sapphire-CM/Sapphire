class ChangeAccountAdminDefault < ActiveRecord::Migration[4.2]
  def up
    change_column :accounts, :admin, :boolean, default: false
  end

  def down
    change_column :accounts, :admin, :boolean
  end
end
