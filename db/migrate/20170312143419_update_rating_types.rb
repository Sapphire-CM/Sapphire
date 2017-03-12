class UpdateRatingTypes < ActiveRecord::Migration
  TYPE_CONVERSIONS = {
    "Ratings::BinaryNumberRating" => "Ratings::FixedPointsDeductionRating",
    "Ratings::BinaryPercentRating" => "Ratings::FixedPercentageDeductionRating",
    "Ratings::ValueNumberRating" => "Ratings::VariablePointsDeductionRating",
    "Ratings::ValuePercentRating" => "Ratings::VariablePercentageDeductionRating"
  }

  def up
    transaction do
      TYPE_CONVERSIONS.each do |from, to|
        execute "UPDATE \"ratings\" SET \"type\" = '#{to}' WHERE \"type\" = '#{from}';"
      end
      execute "UPDATE \"ratings\" SET \"type\" = 'Ratings::PerItemPointsDeductionRating' WHERE \"title\" LIKE '# %' AND \"type\"='Ratings::VariablePointsDeductionRating';"
      execute "UPDATE \"ratings\" SET \"type\" = 'Ratings::VariableBonusPointsRating' WHERE \"title\" LIKE 'bonus: %' AND \"type\"='Ratings::VariablePointsDeductionRating';"
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
      execute "UPDATE \"ratings\" SET \"type\" = '#{to}' WHERE \"type\" = '#{from}';"
    end
  end
end
