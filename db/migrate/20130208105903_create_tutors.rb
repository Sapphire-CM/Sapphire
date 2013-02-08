class CreateTutors < ActiveRecord::Migration
  def change
    create_table :tutors do |t|

      t.timestamps
    end
  end
end
