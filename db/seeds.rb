# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

courses = Course.create([
  { title: 'INM' }, 
  { title: 'HCI' },
  { title: 'Bakk-Proj' }])

terms = Term.create([
  { title: 'WS 2011', course: courses[0] },
  { title: 'WS 2012', course: courses[0] },
  { title: 'SS 2011', course: courses[1] },
  { title: 'SS 2012', course: courses[1] },
  { title: 'SS 2013', course: courses[1] }])

exercises = Exercise.create([
  { title: 'Ex 1: Newsgroup', term: terms[0] },
  { title: 'Ex 2: Follow-ups', term: terms[0] },
  { title: 'Ex 3.1: Email', term: terms[0] },
  { title: 'Ex 3.2: Research', term: terms[0] },
  { title: 'Ex 4: Website', term: terms[0] },
  { title: 'Ex 5: CSS', term: terms[0] }])

rating_groups = RatingGroup.create([
  { title: 'Identity', points: 7, exercise: exercises[0] },
  { title: 'Format', points: 7, exercise: exercises[0] },
  { title: 'Content', points: 11, exercise: exercises[0] },
  { title: 'Miscellaneous', points: 0, exercise: exercises[0] }])

ratings = Rating.create([
  { title: 'no realname', points: -3, rating_group: rating_groups[0] },
  { title: 'wrong or missing TUG or previously disclosed email address', points: -3, rating_group: rating_groups[0] },
  { title: 'redundant Reply-To (same as From)', points: -1, rating_group: rating_groups[0] },
  { title: 'no signature', points: -4, rating_group: rating_groups[0] },
  { title: 'not 100% plain text', points: -5, rating_group: rating_groups[1] },
  { title: 'broken message id', points: -2, rating_group: rating_groups[1] },
  { title: 'headers not 7bit ASCII', points: -2, rating_group: rating_groups[1] },
  { title: 'lines too long', points: -3, rating_group: rating_groups[1]} ])



