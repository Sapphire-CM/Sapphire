class AddGradingScaleToTerm < ActiveRecord::Migration[4.2]
  def change
    add_column :terms, :grading_scale, :text
  end
end
