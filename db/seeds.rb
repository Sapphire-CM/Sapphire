courses = Course.create([
  { title: 'INM' },
  { title: 'HCI' },
  { title: 'Bakk-Proj' }])

terms = Term.create([
  { title: 'WS 2011', course: courses[0] },
  { title: 'WS 2012', course: courses[0] },
  { title: 'WS 2013', course: courses[0] },
  { title: 'SS 2011', course: courses[1] },
  { title: 'SS 2012', course: courses[1] },
  { title: 'SS 2013', course: courses[1] }])

exercises = Exercise.create([
  { title: 'Ex 1: Newsgroup',  term: terms[0] },
  { title: 'Ex 2: Follow-ups', term: terms[0] },
  { title: 'Ex 3.1: Email',    term: terms[0] },
  { title: 'Ex 3.2: Research', term: terms[0] },
  { title: 'Ex 4: Website',    term: terms[0] },
  { title: 'Ex 5: CSS',        term: terms[0] }])

rating_groups = RatingGroup.create([
  { title: 'Identity',         points:  7, exercise: exercises[0] },
  { title: 'Format',           points:  7, exercise: exercises[0] },
  { title: 'Content',          points: 11, exercise: exercises[0] },
  { title: 'General stuff',    points: 10, exercise: exercises[0], global: true },
  { title: 'General stuff 2',  points: 11, exercise: exercises[0] },
  { title: 'Miscellaneous',    points:  0, exercise: exercises[0] }])

binary_number_ratings = BinaryNumberRating.create([
  { title: 'no realname',                        value: -3, rating_group: rating_groups[0] },
  { title: 'wrong or missing TUG or previously disclosed email address', value: -3, rating_group: rating_groups[0] },
  { title: 'redundant Reply-To (same as From)',  value: -1, rating_group: rating_groups[0] },
  { title: 'no signature',                       value: -4, rating_group: rating_groups[0] },
  { title: 'not 100% plain text',                value: -5, rating_group: rating_groups[1] },
  { title: 'broken message id',                  value: -2, rating_group: rating_groups[1] },
  { title: 'headers not 7bit ASCII',             value: -2, rating_group: rating_groups[1] },
  { title: 'lines too long',                     value: -3, rating_group: rating_groups[1]} ])

binary_percent_ratings = BinaryPercentRating.create([
  { title: 'late deadline',       value: -50,  rating_group: rating_groups[1] },
  { title: 'plagiarism',          value: -50,  rating_group: rating_groups[1] },
  { title: 'very well',           value:  30,  rating_group: rating_groups[1] },
  { title: 'general stupidity',   value: -25,  rating_group: rating_groups[1] } ])

value_number_ratings = ValueNumberRating.create([
  { title: 'content of summary',    min_value:  0,   max_value: 10,  rating_group: rating_groups[2] },
  { title: 'style of layout',       min_value: -5,   max_value:  5,  rating_group: rating_groups[2] } ])

