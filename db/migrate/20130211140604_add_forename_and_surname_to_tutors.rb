class AddForenameAndSurnameToTutors < ActiveRecord::Migration
  def change
    add_column :tutors, :forename, :string
    add_column :tutors, :surname, :string
  end
end
