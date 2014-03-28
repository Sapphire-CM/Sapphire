Given(/^all results of exercise "(.*?)" are published$/) do |exercise_title|
  exercise = FactoryGirl.create(:exercise, title: exercise) unless exercise = Exercise.where(title: exercise_title).first

  exercise.result_publications.update_all(published: true)
end
