accounts = Account.create! [
  { email: 'thomas.kriechbaumer@student.tugraz.at', forename: 'Thomas',   surname: 'Kriechbaumer', password: '123456', password_confirmation: '123456', admin: true},
  { email: 'matthias.link@student.tugraz.at',       forename: 'Matthias', surname: 'Link',         password: '654321', password_confirmation: '654321', admin: true},
  { email: 'kandrews@iicm.edu',                     forename: 'Keith',    surname: 'Andrews',      password: '123456', password_confirmation: '123456', admin: true},
  { email: 'john.doe@student.tugraz.at',            forename: 'John',     surname: 'Doe', matriculation_number: '1231567', password: '123456', password_confirmation: '123456'},
  { email: 'jane.doe@student.tugraz.at',            forename: 'Jane',     surname: 'Doe', matriculation_number: '1120321', password: '123456', password_confirmation: '123456'},
  { email: 'jack.doe@student.tugraz.at',            forename: 'Jack',     surname: 'Doe', matriculation_number: '1030765', password: '123456', password_confirmation: '123456'}
]

course_hci = Course.create!({ title: 'HCI' })
course_iaweb = Course.create!({ title: 'IAWEB' })

terms = Term.create! [
  { title: 'SS 2013', course: course_hci },
  { title: 'SS 2014', course: course_hci },
  { title: 'WS 2013', course: course_iaweb }
]
Term.all.map{ |obj| obj.row_order_position = :last; obj.save }

lecturer_registrations = LecturerRegistration.create!({ term: course_hci.terms.first, lecturer: accounts[2] })

tutorial_groups = [
  {title: "T1", description: "First tutorial group"},
  {title: "T2", description: "Second tutorial group"}
].map {|tg_hash| tg = TutorialGroup.new(tg_hash); tg.term = course_hci.terms.first; tg}
tutorial_groups.each {|tg| tg.save}

exercises = Exercise.create! [
  { title: 'Ex 1: Something',  term: course_hci.terms.first, group_submission: true },
  { title: 'MC Test',          term: course_hci.terms.first, group_submission: false }
]
Exercise.all.map{ |obj| obj.row_order_position = :last; obj.save }


require File.join File.dirname(__FILE__), 'seeds_inm.rb'
