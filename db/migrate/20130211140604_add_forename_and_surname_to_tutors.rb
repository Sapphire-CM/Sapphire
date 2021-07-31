class AddForenameAndSurnameToTutors < ActiveRecord::Migration[4.2]
  def change
    add_column :tutors, :forename, :string
    add_column :tutors, :surname, :string
  end
end
