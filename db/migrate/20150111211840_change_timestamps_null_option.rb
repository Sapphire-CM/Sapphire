class ChangeTimestampsNullOption < ActiveRecord::Migration[4.2]
  def change
    ActiveRecord::Base.connection.tables.each do |table|
      [:created_at, :updated_at].each do |column|
        change_column_null table, column, false if column_exists? table, column
      end
    end
  end
end
