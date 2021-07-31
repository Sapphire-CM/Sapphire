class ChangeTimestampsNullOption < ActiveRecord::Migration[4.2]
  RESERVED_TABLES = %w(ar_internal_metadata).freeze

  def change
    ActiveRecord::Base.connection.tables.each do |table|
      next if RESERVED_TABLES.include? table
      [:created_at, :updated_at].each do |column|
        change_column_null table, column, false if column_exists? table, column
      end
    end
  end
end
