class FixTitlesOfPlagiarismRatings < ActiveRecord::Migration
  def change
    Rating.where(type: "Ratings::PlagiarismRating").update_all(title: 'plagiarism')
  end
end
