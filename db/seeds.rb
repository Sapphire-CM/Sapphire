accounts = Account.create([
  { email: 'thomas.kriechbaumer@student.tugraz.at', forename: 'Thomas', surname: 'Kriechbaumer', password: '123456', password_confirmation: '123456'},
  { email: 'matthias.link@student.tugraz.at', forename: 'Matthias', surname: 'Link', password: '654321', password_confirmation: '654321'} ])

courses = Course.create([
  { title: 'INM' },
  { title: 'HCI' },
  { title: 'IAWEB' } ])

terms = Term.create([
  { title: 'WS 2013', course: courses[0] },
  { title: 'WS 2014', course: courses[0] },
  { title: 'SS 2013', course: courses[1] },
  { title: 'SS 2014', course: courses[1] },
  { title: 'WS 2013', course: courses[2] } ])

exercises = Exercise.create([
  { title: 'Ex 1: Newsgroup',  term: terms[0] },
  { title: 'Ex 2: Follow-ups', term: terms[0] },
  { title: 'Ex 3.1: Email',    term: terms[0] },
  { title: 'Ex 3.2: Research', term: terms[0] },
  { title: 'Ex 4: Website',    term: terms[0] },
  { title: 'Ex 5: CSS',        term: terms[0] },
  { title: 'MC Test',          term: terms[0] } ])

rating_groups = RatingGroup.create([
  { title: 'Identity',                points:   7, exercise: exercises[0] },
  { title: 'Format',                  points:   7, exercise: exercises[0] },
  { title: 'Content',                 points:  11, exercise: exercises[0] },
  { title: 'General',                 points: nil, exercise: exercises[0], global: true },

  { title: 'Identity',                points:   7, exercise: exercises[1] },
  { title: 'Format',                  points:   7, exercise: exercises[1] },
  { title: 'Quoting',                 points:  10, exercise: exercises[1] },
  { title: 'Content',                 points:   6, exercise: exercises[1] },
  { title: 'General',                 points: nil, exercise: exercises[1], global: true },

  { title: 'Identity & Format',       points:  15, exercise: exercises[2] },
  { title: 'General',                 points: nil, exercise: exercises[2], global: true },

  { title: 'PDF',                     points:   5, exercise: exercises[3] },
  { title: 'Person',                  points:   3, exercise: exercises[3] },
  { title: 'Publication',             points:  10, exercise: exercises[3] },
  { title: 'Summary',                 points:  10, exercise: exercises[3] },
  { title: 'General',                 points: nil, exercise: exercises[3], global: true },

  { title: 'Files & Directories',     points:   7, exercise: exercises[4] },
  { title: 'Index.xhtml',             points:   7, exercise: exercises[4] },
  { title: 'Posting.xhtml',           points:   7, exercise: exercises[4] },
  { title: 'Person.xhtml',            points:   7, exercise: exercises[4] },
  { title: 'XHTML elements',          points:   7, exercise: exercises[4] },
  { title: 'Image (anywhere)',        points:   7, exercise: exercises[4] },
  { title: 'inm.css',                 points:   7, exercise: exercises[4] },
  { title: 'XHTML coding (anywhere)', points:   7, exercise: exercises[4] },
  { title: 'General',                 points: nil, exercise: exercises[4], global: true },

  { title: 'Email format',            points:  10, exercise: exercises[5] },
  { title: 'graztimes.css',           points:  10, exercise: exercises[5] },
  { title: 'print.css',               points:  10, exercise: exercises[5] },
  { title: 'kids.css',                points:  10, exercise: exercises[5] },
  { title: 'General',                 points: nil, exercise: exercises[5], global: true },

  { title: 'Questions',               points:  40, exercise: exercises[6] },
  { title: 'General',                 points: nil, exercise: exercises[6], global: true } ])

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

