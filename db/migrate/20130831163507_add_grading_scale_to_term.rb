class AddGradingScaleToTerm < ActiveRecord::Migration
  def change
    add_column :terms, :grading_scale, :text
  end
end
