class CreateEmailAddresses < ActiveRecord::Migration
  def change
    create_table :email_addresses do |t|
      t.string :email
      t.belongs_to :account, index: true

      t.timestamps
    end
  end
end
