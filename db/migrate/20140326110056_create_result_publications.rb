class CreateResultPublications < ActiveRecord::Migration
  def change
    create_table :result_publications do |t|
      t.belongs_to :exercise, index: true
      t.belongs_to :tutorial_group, index: true
      t.boolean :published, default: false

      t.timestamps
    end
  end

  def up
    Exercise.all.each do |exercise|
      exercise.send(:ensure_result_publications)
    end
  end
end
