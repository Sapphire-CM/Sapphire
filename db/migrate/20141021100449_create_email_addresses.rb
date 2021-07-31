class CreateEmailAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :email_addresses do |t|
      t.string :email
      t.belongs_to :account, index: true

      t.timestamps null: false
    end
  end
end
