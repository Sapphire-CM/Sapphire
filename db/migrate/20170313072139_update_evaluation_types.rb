class UpdateEvaluationTypes < ActiveRecord::Migration[4.2]
  TYPE_CONVERSIONS = {
    "Evaluations::BinaryEvaluation" => "Evaluations::FixedEvaluation",
    "Evaluations::ValueEvaluation" => "Evaluations::VariableEvaluation",
  }

  def up
    transaction do
      TYPE_CONVERSIONS.each do |from, to|
        execute "UPDATE \"evaluations\" SET \"type\" = '#{to}' WHERE \"type\" = '#{from}';"
      end
    end

    say <<-MESSAGE
MANUAL ACTION REQUIRED!

Make sure to check if all ratings are valid!

    invalid_ratings = Rating.all.to_a.delete_if(&:valid?)
    unless invalid_ratings.empty?
      puts "There are invalid ratings"
      puts invalid_ratings.map { |r| [r.id, r.title].join(" - ") }
    end
MESSAGE
  end

  def down
    TYPE_CONVERSIONS.each do |to, from|
      execute "UPDATE \"evaluations\" SET \"type\" = '#{to}' WHERE \"type\" = '#{from}';"
    end
  end
end
