class FixTitlesOfPlagiarismRatings < ActiveRecord::Migration[4.2]
  def change
    Rating.where(type: "Ratings::PlagiarismRating").update_all(title: 'plagiarism')
  end
end
