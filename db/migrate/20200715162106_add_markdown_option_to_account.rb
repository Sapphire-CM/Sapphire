class AddMarkdownOptionToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :comment_markdown_preference, :boolean, default: false
  end
end
