class AddMarkdownOptionToAccount < ActiveRecord::Migration[4.2]
  def change
    add_column :accounts, :comment_markdown_preference, :boolean, default: false
  end
end
