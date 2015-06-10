class FixStiModelNamespaces < ActiveRecord::Migration
  def up
    return unless Rails.configuration.database_configuration[Rails.env]['adapter'] == 'postgresql'
    [Evaluation, Export, Rating, Service].each do |klass|
      klass.connection.execute(
        "UPDATE #{klass.table_name} SET type=CONCAT('#{klass.to_s.pluralize}::', type);")
    end
  end

  def down
    return unless Rails.configuration.database_configuration[Rails.env]['adapter'] == 'postgresql'
    [Evaluation, Export, Rating, Service].each do |klass|
      klass.connection.execute(
        "UPDATE #{klass.table_name} SET type=RIGHT(type, LENGTH(type) - #{klass.to_s.pluralize.length + 2});")
    end
  end
end
