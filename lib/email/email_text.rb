def create_email_text(tutorial_group_index, student_index)
  famous_person = $famous_persons[tutorial_group_index][student_index % 5]

  text = <<-EOF
Web Research
------------

You should research into the following computer scientist:

#{famous_person[:name]}

  IEEE: #{famous_person[:ieee][:page_count]} pages, MD5: #{famous_person[:ieee][:hash]}
   ACM: #{famous_person[:acm][:page_count]} pages, MD5: #{famous_person[:acm][:hash]}

Before you start, read the detailed instructions at:

http://courses.iicm.tugraz.at/inm/exercises/exer3.html

When you have finished your essay and created your PDF file, you will
need to upload it to the following TU Graz Teach Center room:

#{$tugtc_rooms[tutorial_group_index]}

Note that there is one room for each tutorial group.

EOF

text << "-- \n" + <<EOF
Good luck!
#{$tutors[tutorial_group_index][:name]}
EOF

  text
end
