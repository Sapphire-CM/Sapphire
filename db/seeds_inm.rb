course_inm = Course.create!({ title: 'INM' })
term_inm = course_inm.terms.create!({ title: 'WS 2013' })

TermRegistration.create! account: Account.find_by(email: 'kandrews@iicm.edu'), term: term_inm, role: Roles::LECTURER

ex_1  = Exercise.create!({ title: 'Ex 1: Newsgroup',  term: term_inm })
ex_2  = Exercise.create!({ title: 'Ex 2: Follow-ups', term: term_inm })
ex_31 = Exercise.create!({ title: 'Ex 3.1: Email',    term: term_inm })
ex_32 = Exercise.create!({ title: 'Ex 3.2: Research', term: term_inm })
ex_4  = Exercise.create!({ title: 'Ex 4: Website',    term: term_inm })
ex_5  = Exercise.create!({ title: 'Ex 5: CSS',        term: term_inm })
ex_6  = Exercise.create!({ title: 'MC Test',          term: term_inm, enable_min_required_points: true, min_required_points: 4 })
Exercise.all.map{ |obj| obj.row_order_position = :last; obj.save }

rating_groups = RatingGroup.create! [
  { title: 'Identity',                points:   7, exercise: ex_1 },    # 0
  { title: 'Format',                  points:   7, exercise: ex_1 },    # 1
  { title: 'Content',                 points:  11, exercise: ex_1 },    # 2
  { title: 'Miscellaneous',           exercise: ex_1, global: true },   # 3

  { title: 'Identity',                points:   7, exercise: ex_2 },    # 4
  { title: 'Format',                  points:   7, exercise: ex_2 },    # 5
  { title: 'Quoting',                 points:  10, exercise: ex_2 },    # 6
  { title: 'Content',                 points:   6, exercise: ex_2 },    # 7
  { title: 'Miscellaneous',           exercise: ex_2, global: true },   # 8

  { title: 'Identity & Format',       points:  15, exercise: ex_31 },   # 9
  { title: 'Miscellaneous',           exercise: ex_31, global: true },  # 10

  { title: 'PDF',                     points:   5, exercise: ex_32 },   # 11
  { title: 'Person',                  points:   3, exercise: ex_32 },   # 12
  { title: 'Publication',             points:  10, exercise: ex_32 },   # 13
  { title: 'Summary',                 points:  10, exercise: ex_32 },   # 14
  { title: 'Miscellaneous',           exercise: ex_32, global: true },  # 15

  { title: 'Files & Directories',     points:   5, exercise: ex_4 },    # 16
  { title: 'Index.xhtml',             points:  10, exercise: ex_4 },    # 17
  { title: 'Posting.xhtml',           points:   5, exercise: ex_4 },    # 18
  { title: 'Person.xhtml',            points:   5, exercise: ex_4 },    # 19
  { title: 'XHTML elements',          points:  10, exercise: ex_4 },    # 20
  { title: 'Image (anywhere)',        points:   4, exercise: ex_4 },    # 21
  { title: 'inm.css',                 points:   5, exercise: ex_4 },    # 22
  { title: 'XHTML coding (anywhere)', points:   0, exercise: ex_4, min_points: -20, max_points: 0, enable_range_points: true },    # 23
  { title: 'Miscellaneous',           exercise: ex_4, global: true },   # 24

  { title: 'Email format',            points:  10, exercise: ex_5 },    # 25
  { title: 'graztimes.css',           points:  10, exercise: ex_5 },    # 26
  { title: 'print.css',               points:  10, exercise: ex_5 },    # 27
  { title: 'kids.css',                points:  10, exercise: ex_5 },    # 28
  { title: 'Miscellaneous',           exercise: ex_5, global: true },   # 29

  { title: 'Questions',               points:  0, exercise: ex_6, min_points: 0, max_points: 40, enable_range_points: true },    # 30
  { title: 'Miscellaneous',           exercise: ex_6, global: true }    # 31
]
RatingGroup.all.map{ |obj| obj.row_order_position = :last; obj.save }




FixedPointsDeductionRating.create! [
  { title: 'no realname',                        value: -3, rating_group: rating_groups[0] },
  { title: 'wrong or missing TUG or previously disclosed email address', value: -3, rating_group: rating_groups[0] },
  { title: 'redundant Reply-To (same as From)',  value: -1, rating_group: rating_groups[0] },
  { title: 'no signature',                       value: -4, rating_group: rating_groups[0] },
  { title: 'signature separator not "-- "',      value: -2, rating_group: rating_groups[0] },
  { title: 'signature > 4 lines',                value: -2, rating_group: rating_groups[0] }
]

FixedPointsDeductionRating.create! [
  { title: 'not 100% plain text',                value: -5, rating_group: rating_groups[1] },
  { title: 'broken message ID',                  value: -2, rating_group: rating_groups[1] },
  { title: 'headers not 7bit ASCII',             value: -2, rating_group: rating_groups[1] },
  { title: 'lines too long (>76 or broken)',     value: -3, rating_group: rating_groups[1] },
  { title: 'badly formatted text',               value: -2, rating_group: rating_groups[1] },
  { title: 'not a news client (e.g. webnews)',   value: -7, rating_group: rating_groups[1] },
  { title: 'bad char set in body (not UTF-8)',   value: -2, rating_group: rating_groups[1]}
]

FixedPointsDeductionRating.create! [
  { title: 'not a new thread',                              value: -8, rating_group: rating_groups[2] },
  { title: 'subject line not 7-bit ASCII',                  value: -2, rating_group: rating_groups[2] },
  { title: 'subject does not reflect content',              value: -2, rating_group: rating_groups[2] },
  { title: 'less than 100 words',                           value: -4, rating_group: rating_groups[2] },
  { title: 'multiple identical postings',                   value: -2, rating_group: rating_groups[2] },
  { title: 'no background info / context / only wikipedia', value: -2, rating_group: rating_groups[2] },
  { title: 'no own opinion',                                value: -2, rating_group: rating_groups[2] },
  { title: 'no questions',                                  value: -2, rating_group: rating_groups[2] },
  { title: 'only one question',                             value: -1, rating_group: rating_groups[2] },
  { title: 'posted in wrong newsgroup',                     value: -3, rating_group: rating_groups[2] },
  { title: 'no quotation marks around quotation',           value: -2, rating_group: rating_groups[2] },
  { title: 'partly not own words (bad paraphrasing)',       value: -5, rating_group: rating_groups[2] },
  { title: 'copied content, but source cited (little own work)', value: -11, rating_group: rating_groups[2]}
]






FixedPointsDeductionRating.create! [
  { title: 'no realname in "From:"',             value: -3, rating_group: rating_groups[4] },
  { title: 'no TUG or previously disclosed address at all', value: -3, rating_group: rating_groups[4] },
  { title: 'redundant Followup-To',              value: -1, rating_group: rating_groups[4] },
  { title: 'redundant Reply-To (same as From)',  value: -1, rating_group: rating_groups[4] },
  { title: 'no signature',                       value: -4, rating_group: rating_groups[4] },
  { title: 'signature separator not "-- "',      value: -2, rating_group: rating_groups[4] },
  { title: 'signature > 4 lines',                value: -2, rating_group: rating_groups[4] }
]

FixedPointsDeductionRating.create! [
  { title: 'not 100% plain text',                value: -5, rating_group: rating_groups[5] },
  { title: 'broken message ID',                  value: -2, rating_group: rating_groups[5] },
  { title: 'not a news client (e.g. webnews)',   value: -7, rating_group: rating_groups[5] },
  { title: 'headers not 7bit ASCII',             value: -1, rating_group: rating_groups[5] },
  { title: 'lines too long (>76 or broken)',     value: -3, rating_group: rating_groups[5] },
  { title: 'bad char set in body (not UTF-8)',   value: -2, rating_group: rating_groups[5]}
]

FixedPointsDeductionRating.create! [
  { title: 'full quote (TOFU and TUFO)',                       value: -10, rating_group: rating_groups[6] },
  { title: 'not quoted at all',                                value: -10, rating_group: rating_groups[6] },
  { title: 'selective but still full quote',                   value:  -5, rating_group: rating_groups[6] },
  { title: 'bad quotation (sig quoted, too little, too much)', value:  -4, rating_group: rating_groups[6] },
  { title: 'no quote characters at all',                       value: -10, rating_group: rating_groups[6] },
  { title: 'some quite characters missing / leading spaces',   value:  -5, rating_group: rating_groups[6] },
  { title: 'no attribution line',                              value:  -3, rating_group: rating_groups[6] },
  { title: 'attribution line too long',                        value:  -2, rating_group: rating_groups[6] }
]

FixedPointsDeductionRating.create! [
  { title: 'not a followup but new thread',                         value: -6, rating_group: rating_groups[7] },
  { title: 'no external followups (to other threads)',              value: -4, rating_group: rating_groups[7] },
  { title: 'only one external followup (to only one other thread)', value: -2, rating_group: rating_groups[7] },
  { title: 'too short / not meaningful / "me too"',                 value: -4, rating_group: rating_groups[7] },
  { title: 'posted to wrong newsgroup',                             value: -3, rating_group: rating_groups[7] }
]






FixedPointsDeductionRating.create! [
  { title: 'no realname in "From"',                                                value:  -3, rating_group: rating_groups[9] },
  { title: 'no TUG or previously disclosed address at all',                        value:  -3, rating_group: rating_groups[9] },
  { title: 'no or invalid TUG or previously disclosed address in "From/ReployTo"', value:  -2, rating_group: rating_groups[9] },
  { title: 'redundant Reply-To (same as From)',                                    value:  -2, rating_group: rating_groups[9] },
  { title: 'no signature',                                                         value:  -4, rating_group: rating_groups[9] },
  { title: 'signature-seperator not "-- "',                                        value:  -2, rating_group: rating_groups[9] },
  { title: 'signature >4 lines',                                                   value:  -2, rating_group: rating_groups[9] },
  { title: 'not 100% plain text (HTML, ...)',                                      value:  -8, rating_group: rating_groups[9] },
  { title: 'e-mail to wrong tutor',                                                value:  -3, rating_group: rating_groups[9] },
  { title: 'tutor not in To:',                                                     value:  -2, rating_group: rating_groups[9] },
  { title: 'no subject line',                                                      value:  -2, rating_group: rating_groups[9] },
  { title: 'subject or header lines not 7-bit ASCII',                              value:  -2, rating_group: rating_groups[9] },
  { title: 'non confirming subject',                                               value:  -2, rating_group: rating_groups[9] },
  { title: 'lines too long/broken',                                                value:  -3, rating_group: rating_groups[9] },
  { title: 'bad charset in body (not UTF-8)',                                      value:  -2, rating_group: rating_groups[9] },
  { title: 'strange characters in mail body',                                      value:  -2, rating_group: rating_groups[9] },
  { title: 'not a mail client (webmail, ...)',                                     value: -10, rating_group: rating_groups[9] },
  { title: 'no mail to own TU mail',                                               value:  -4, rating_group: rating_groups[9] },
  { title: 'mail to TU email in TO rather than CC',                                value:  -2, rating_group: rating_groups[9] },
  { title: 'multiple mails in short time',                                         value:  -2, rating_group: rating_groups[9] }
]



















FixedPointsDeductionRating.create! [
  { title: 'uploaded to wrong room',                                 value: -5, rating_group: rating_groups[11] },
  { title: 'not a PDF',                                              value: -3, rating_group: rating_groups[11] },
  { title: 'text is actually an image, hence no automatic analysis', value: -5, rating_group: rating_groups[11] },
  { title: 'filesize > 1mb',                                         value: -3, rating_group: rating_groups[11] },
  { title: 'at least one link do not work',                          value: -3, rating_group: rating_groups[11] },
  { title: 'wrong file name',                                        value: -3, rating_group: rating_groups[11] },
  { title: 'not used provided template',                             value: -5, rating_group: rating_groups[11] },
]

FixedPointsDeductionRating.create! [
  { title: 'missing',                         value: -3, rating_group: rating_groups[12] },
  { title: 'name: omitted or wrong',          value: -2, rating_group: rating_groups[12] },
  { title: 'name: incomplete',                value: -1, rating_group: rating_groups[12] },
  { title: 'name: source missing or wrong',   value: -1, rating_group: rating_groups[12] },
  { title: 'famous: omitted or wrong',        value: -2, rating_group: rating_groups[12] },
  { title: 'famous: incomplete',              value: -1, rating_group: rating_groups[12] },
  { title: 'famous: source missing or wrong', value: -1, rating_group: rating_groups[12] },
  { title: 'study: omitted or wrong',         value: -2, rating_group: rating_groups[12] },
  { title: 'study: incomplete',               value: -1, rating_group: rating_groups[12] },
  { title: 'study:source missing or wrong',   value: -1, rating_group: rating_groups[12] },
]

FixedPointsDeductionRating.create! [
  { title: 'ACM missing',                                           value: -5, rating_group: rating_groups[13] },
  { title: 'ACM pub: omitted or wrong',                             value: -5, rating_group: rating_groups[13] },
  { title: 'ACM pub title: omitted or wrong',                       value: -2, rating_group: rating_groups[13] },
  { title: 'ACM pub title: incomplete',                             value: -1, rating_group: rating_groups[13] },
  { title: 'ACM pub author(s): omitted or wrong',                   value: -2, rating_group: rating_groups[13] },
  { title: 'ACM pub author(s): incomplete',                         value: -1, rating_group: rating_groups[13] },
  { title: 'ACM pub where published: omitted or wrong',             value: -2, rating_group: rating_groups[13] },
  { title: 'ACM pub where published: incomplete',                   value: -1, rating_group: rating_groups[13] },
  { title: 'ACM pub publication month and year: omitted or wrong',  value: -2, rating_group: rating_groups[13] },
  { title: 'ACM pub publication month and year incomplete',         value: -1, rating_group: rating_groups[13] },
  { title: 'ACM pub page numbers: omitted or wrong',                value: -2, rating_group: rating_groups[13] },
  { title: 'ACM pub page numbers: incomplete',                      value: -1, rating_group: rating_groups[13] },
  { title: 'ACM pub DOI: omitted or wrong',                         value: -2, rating_group: rating_groups[13] },
  { title: 'ACM pub DOI: incomplete',                               value: -1, rating_group: rating_groups[13] },
  { title: 'IEEE missing',                                          value: -5, rating_group: rating_groups[13] },
  { title: 'IEEE pub: omitted or wrong',                            value: -5, rating_group: rating_groups[13] },
  { title: 'IEEE pub title: omitted or wrong',                      value: -2, rating_group: rating_groups[13] },
  { title: 'IEEE pub title: incomplete',                            value: -1, rating_group: rating_groups[13] },
  { title: 'IEEE pub author(s): omitted or wrong',                  value: -2, rating_group: rating_groups[13] },
  { title: 'IEEE pub author(s): incomplete',                        value: -1, rating_group: rating_groups[13] },
  { title: 'IEEE pub where published: omitted or wrong',            value: -2, rating_group: rating_groups[13] },
  { title: 'IEEE pub where published: incomplete',                  value: -1, rating_group: rating_groups[13] },
  { title: 'IEEE pub publication month and year: omitted or wrong', value: -2, rating_group: rating_groups[13] },
  { title: 'IEEE pub publication month and year: incomplete',       value: -1, rating_group: rating_groups[13] },
  { title: 'IEEE:pub page numbers: ommited or wrong',               value: -2, rating_group: rating_groups[13] },
  { title: 'IEEE:pub pagenumbers: incomplete',                      value: -1, rating_group: rating_groups[13] },
  { title: 'IEEE pub DOI: omitted or wrong',                        value: -2, rating_group: rating_groups[13] },
  { title: 'IEEE pub DOI: incomplete',                              value: -1, rating_group: rating_groups[13] },
]

FixedPointsDeductionRating.create! [
  { title: 'missing', value: -10, rating_group: rating_groups[14] },
]

VariablePointsDeductionRating.create! [
  { title: 'content', min_value: 0, max_value: 5, rating_group: rating_groups[14] },
]

FixedPointsDeductionRating.create! [
  { title: 'quotation: omitted',                         value: -2, rating_group: rating_groups[14] },
  { title: 'quotation: wrong quotation',                 value: -1, rating_group: rating_groups[14] },
  { title: 'quotation: no quotation marks around quote', value: -2, rating_group: rating_groups[14] },
  { title: 'reference: omitted or wrong',                value: -2, rating_group: rating_groups[14] },
  { title: 'reference: incomplete',                      value: -1, rating_group: rating_groups[14] },
  { title: 'all URL abbreviation used (e.g. TinyURL)',   value: -3, rating_group: rating_groups[14] },
  { title: 'summary not enough words / too many words',  value: -3, rating_group: rating_groups[14] },
  { title: 'copied content, but source cited',           value: -10, rating_group: rating_groups[14] },
  { title: 'partly not own words (bad paraphrasing)',    value: -5, rating_group: rating_groups[14] },
]







FixedPointsDeductionRating.create! [
  { title: 'no INM subdirectory',                           value: -3, rating_group: rating_groups[16] },
  { title: 'index.xhtml exists but wrong name/dir',         value: -2, rating_group: rating_groups[16] },
  { title: 'posting.xhtml exists but wrong name/dir',       value: -2, rating_group: rating_groups[16] },
  { title: 'researcher.xhtml exists but wrong name/dir',    value: -2, rating_group: rating_groups[16] },
  { title: 'inm.css exists but wrong name/dir',             value: -2, rating_group: rating_groups[16] },
  { title: 'superfluous/redundant files  ',                 value: -2, rating_group: rating_groups[16] },
  { title: 'bad/uppercase characters in any file/dir name', value: -3, rating_group: rating_groups[16] },
]

FixedPointsDeductionRating.create! [
  { title: 'no index page or page w/o content/wrong content',              value: -10, rating_group: rating_groups[17] },
  { title: 'not simple html (word, frontpage, etc)',                       value: -5, rating_group: rating_groups[17] },
  { title: '<100 words about favourite city',                              value: -3, rating_group: rating_groups[17] },
  { title: 'no photography/image  from the city',                          value: -1, rating_group: rating_groups[17] },
  { title: 'less then 3 pieces of statistical information about the city', value: -1, rating_group: rating_groups[17] },
  { title: 'statistical infos not in table',                               value: -2, rating_group: rating_groups[17] },
  { title: 'no nav element in index.html',                                 value: -2, rating_group: rating_groups[17] },
  { title: 'no working absolute link to city info',                        value: -1, rating_group: rating_groups[17] },
  { title: 'no relative link to posting.html',                             value: -2, rating_group: rating_groups[17] },
  { title: 'no relative link to person.html',                              value: -2, rating_group: rating_groups[17] },
  { title: 'links not clickable',                                          value: -1, rating_group: rating_groups[17] },
  { title: 'doctype for xhtml5 faulty or missing',                         value: -4, rating_group: rating_groups[17] },
  { title: 'bad paraphrasing',                                             value: -5, rating_group: rating_groups[17] },
  { title: 'fails W3C validator',                                          value: -7, rating_group: rating_groups[17] },
]

FixedPointsDeductionRating.create! [
  { title: 'no posting page or page w/o content',    value: -5, rating_group: rating_groups[18] },
  { title: 'links not clickable',                    value: -1, rating_group: rating_groups[18] },
  { title: 'not simple html (word, frontpage, etc)', value: -4, rating_group: rating_groups[18] },
  { title: 'doctype for xhtml5 faulty or missing',   value: -2, rating_group: rating_groups[18] },
  { title: 'fails W3C validator',                    value: -4, rating_group: rating_groups[18] },
]

FixedPointsDeductionRating.create! [
  { title: 'no person page or page w/o content',                       value: -5, rating_group: rating_groups[19] },
  { title: 'not simple html (word, frontpage, etc)',                   value: -4, rating_group: rating_groups[19] },
  { title: 'what is the person most famous for missed ',               value: -1, rating_group: rating_groups[19] },
  { title: 'education info missing',                                   value: -1, rating_group: rating_groups[19] },
  { title: 'reference to the most recent publication in ACM missing',  value: -1, rating_group: rating_groups[19] },
  { title: 'DOI missing (ACM)/not generic',                            value: -1, rating_group: rating_groups[19] },
  { title: 'DOI present but not clickable (ACM)',                      value: -1, rating_group: rating_groups[19] },
  { title: 'reference to the most recent publication in IEEE missing', value: -1, rating_group: rating_groups[19] },
  { title: 'DOI missing (IEEE)/not generic',                           value: -1, rating_group: rating_groups[19] },
  { title: 'DOI present but not clickable (IEEE)',                     value: -1, rating_group: rating_groups[19] },
  { title: 'summary of  person\'s publication missed (IEEE)',          value: -2, rating_group: rating_groups[19] },
  { title: 'full reference for summary quotation missing',             value: -1, rating_group: rating_groups[19] },
  { title: 'links not clickable',                                      value: -1, rating_group: rating_groups[19] },
  { title: 'doctype for xhtml5 faulty or missing',                     value: -2, rating_group: rating_groups[19] },
  { title: 'fails W3C validator',                                      value: -4, rating_group: rating_groups[19] },
]

FixedPointsDeductionRating.create! [
  { title: 'h1 missing',                            value: -2, rating_group: rating_groups[20] },
  { title: 'h2 missing',                            value: -2, rating_group: rating_groups[20] },
  { title: 'p missing',                             value: -2, rating_group: rating_groups[20] },
  { title: 'em missing',                            value: -2, rating_group: rating_groups[20] },
  { title: 'ol missing',                            value: -2, rating_group: rating_groups[20] },
  { title: 'ul missing',                            value: -2, rating_group: rating_groups[20] },
  { title: 'section missing',                       value: -2, rating_group: rating_groups[20] },
  { title: 'footer missing',                        value: -2, rating_group: rating_groups[20] },
  { title: 'table missing',                         value: -2, rating_group: rating_groups[20] },
  { title: 'thead/tbody/tfoot missing',             value: -2, rating_group: rating_groups[20] },
  { title: 'utf-8 right arrow missing',             value: -2, rating_group: rating_groups[20] },
  { title: 'no or wrong utf-8 qutation characters', value: -2, rating_group: rating_groups[20] },
  { title: 'no blockquote (in researcher)',         value: -2, rating_group: rating_groups[20] },
]

FixedPointsDeductionRating.create! [
  { title: 'no img element on any page',                    value: -4, rating_group: rating_groups[21] },
  { title: 'at least one image with missing src attribute', value: -4, rating_group: rating_groups[21] },
  { title: 'at least one image from remote server',         value: -4, rating_group: rating_groups[21] },
  { title: 'at least one wrong src for local image',        value: -4, rating_group: rating_groups[21] },
  { title: 'at least one image > 50kb',                     value: -2, rating_group: rating_groups[21] },
  { title: 'at least one image in wrong format',            value: -2, rating_group: rating_groups[21] },
  { title: 'at least one img width missing or wrong',       value: -2, rating_group: rating_groups[21] },
  { title: 'at least one img height missing or wrong',      value: -2, rating_group: rating_groups[21] },
  { title: 'at least one img alt missing or wrong',         value: -2, rating_group: rating_groups[21] },
]

FixedPointsDeductionRating.create! [
  { title: 'no stylesheet at all',                                              value: -5, rating_group: rating_groups[22] },
  { title: 'stylesheet not linked correctly on all pages',                      value: -4, rating_group: rating_groups[22] },
  { title: 'no/incomplete image frame (border, padding, and background-color)', value: -1, rating_group: rating_groups[22] },
  { title: 'text colour not #020101',                                           value: -1, rating_group: rating_groups[22] },
  { title: 'background not #f6f4f6',                                            value: -1, rating_group: rating_groups[22] },
  { title: 'body text not font-family sans-serif',                              value: -1, rating_group: rating_groups[22] },
  { title: 'h1 - h6 not font-family serif or not bold',                         value: -1, rating_group: rating_groups[22] },
  { title: 'fails W3C validator',                                               value: -4, rating_group: rating_groups[22] },
]

FixedPointsDeductionRating.create! [
  { title: 'lines too long (> 90)',                                                                                                              value: -3, rating_group: rating_groups[23] },
  { title: 'style attribute or style tag used',                                                                                                  value: -3, rating_group: rating_groups[23] },
  { title: 'wrong usage of logical elements (e.g. em just to make text italic, blockquote for text which is not a quotation, table for layout)', value: -5, rating_group: rating_groups[23] },
  { title: 'div or span used where other tag was appropriate (e.g. <div class="heading"> instead of <h1>)',                                      value: -5, rating_group: rating_groups[23] },
  { title: 'bad element names (e.g. <h1 class="red">, <div id="left">)',                                                                         value: -5, rating_group: rating_groups[23] },
  { title: 'layout elements/attributes used (e.g. <i>, width, border)',                                                                          value: -5, rating_group: rating_groups[23] },
  { title: 'improper formatting (e.g. entire posting plain text in one <p>)',                                                                    value: -5, rating_group: rating_groups[23] },
  { title: 'wrong or missing charset',                                                                                                           value: -2, rating_group: rating_groups[23] },
  { title: 'br element used',                                                                                                                    value: -5, rating_group: rating_groups[23] }
]







FixedPointsDeductionRating.create! [
  { title: 'sent to wrong tutor',                              value: -5, rating_group: rating_groups[25] },
  { title: 'no realname in "From:"',                           value: -3, rating_group: rating_groups[25] },
  { title: 'no TUG or previously disclosed address at all',    value: -3, rating_group: rating_groups[25] },
  { title: 'redundant Reply-To (same as From)',                value: -2, rating_group: rating_groups[25] },
  { title: 'no sig',                                           value: -3, rating_group: rating_groups[25] },
  { title: 'sig-separator not "-- "',                          value: -2, rating_group: rating_groups[25] },
  { title: 'sig >4 lines',                                     value: -2, rating_group: rating_groups[25] },
  { title: 'not 100% plain text (HTML, Vicard...)',            value: -8, rating_group: rating_groups[25] },
  { title: 'tutor not in To:',                                 value: -2, rating_group: rating_groups[25] },
  { title: 'no subject line',                                  value: -2, rating_group: rating_groups[25] },
  { title: 'subject or header lines not 7-bit ASCII',          value: -2, rating_group: rating_groups[25] },
  { title: 'subject not "[INM] MatrNr Exercise 5 Submission"', value: -2, rating_group: rating_groups[25] },
  { title: 'lines too long (>76) / broken',                    value: -3, rating_group: rating_groups[25] },
  { title: 'bad char set',                                     value: -2, rating_group: rating_groups[25] },
  { title: 'not mail client (Webmail, ...)',                   value: -6, rating_group: rating_groups[25] },
  { title: 'strange characters in mail body',                  value: -2, rating_group: rating_groups[25] },
  { title: 'no mail to self (neither in CC nor in To)',        value: -4, rating_group: rating_groups[25] },
  { title: 'mail to self in To rather than CC',                value: -2, rating_group: rating_groups[25] },
  { title: 'attachments in zip/rar',                           value: -2, rating_group: rating_groups[25] },
  { title: 'extra files sent',                                 value: -2, rating_group: rating_groups[25] },
  { title: 'body text not as specified',                       value: -2, rating_group: rating_groups[25] },
  { title: 'multiple mails in short time',                     value: -2, rating_group: rating_groups[25] },
]

FixedPointsDeductionRating.create! [
  { title: 'file not found',                                    value: -10, rating_group: rating_groups[26] },
  { title: 'graztimes.css exists but wrong name or dir',        value: -2, rating_group: rating_groups[26] },
  { title: 'one wrong layout',                                  value: -3, rating_group: rating_groups[26] },
  { title: 'two/three layouts wrong',                           value: -7, rating_group: rating_groups[26] },
  { title: 'not all sizes in % or em, ex, rem',                 value: -3, rating_group: rating_groups[26] },
  { title: 'not responsive (no switching, wrong breakpoints)',  value: -5, rating_group: rating_groups[26] },
  { title: 'not perfectly responsive',                          value: -2, rating_group: rating_groups[26] },
  { title: 'global-nav list not horizontal or bullets visible', value: -2, rating_group: rating_groups[26] },
  { title: 'figure caption not beneath or visible in narrow',   value: -2, rating_group: rating_groups[26] },
  { title: 'global-nav is not two-level drop-down menu',        value: -2, rating_group: rating_groups[26] },
  { title: 'prices not yellow background (only in stories)',    value: -2, rating_group: rating_groups[26] },
  { title: 'fails css validator',                               value: -7, rating_group: rating_groups[26] },
]

FixedPointsDeductionRating.create! [
  { title: 'file not found',                                               value: -10, rating_group: rating_groups[27] },
  { title: 'print.css exists but wrong name or dir',                       value: -2, rating_group: rating_groups[27] },
  { title: 'wrong layout (must be single column)',                         value: -7, rating_group: rating_groups[27] },
  { title: 'body text not Times New Roman and serif at 12pt',              value: -2, rating_group: rating_groups[27] },
  { title: 'all other sizes not in %, pt or em',                           value: -3, rating_group: rating_groups[27] },
  { title: 'headings not bold and Verdana or fallback not sans serif',     value: -2, rating_group: rating_groups[27] },
  { title: 'h1 and tagline not separated by thin line',                    value: -2, rating_group: rating_groups[27] },
  { title: 'links underlined, not bold, or not colour #005604',            value: -2, rating_group: rating_groups[27] },
  { title: 'not black on white',                                           value: -2, rating_group: rating_groups[27] },
  { title: 'image caption is not beneath the image',                       value: -1, rating_group: rating_groups[27] },
  { title: 'logo-link or destination visible',                             value: -2, rating_group: rating_groups[27] },
  { title: 'global-nav is visible or takes up space',                      value: -2, rating_group: rating_groups[27] },
  { title: 'copyright text not centered',                                  value: -2, rating_group: rating_groups[27] },
  { title: 'text in stories and specials does not flow around images',     value: -2, rating_group: rating_groups[27] },
  { title: 'e-mail address visible or takes up space',                     value: -2, rating_group: rating_groups[27] },
  { title: 'destination of link does not follow or not angle brackets',    value: -2, rating_group: rating_groups[27] },
  { title: 'long form does not precede abbreviation in parentheses',       value: -2, rating_group: rating_groups[27] },
  { title: 'footer not separated by thin solid border of colour #252525',  value: -2, rating_group: rating_groups[27] },
  { title: 'fails css validator',                                          value: -7, rating_group: rating_groups[27] },
]

FixedPointsDeductionRating.create! [
  { title: 'file not found',                                    value: -10, rating_group: rating_groups[28] },
  { title: 'kids.css exists but wrong name or dir',             value: -2, rating_group: rating_groups[28] },
  { title: 'one wrong layout',                                  value: -3, rating_group: rating_groups[28] },
  { title: 'two/three layouts wrong',                           value: -7, rating_group: rating_groups[28] },
  { title: 'not all sizes in % or em, ex, rem',                 value: -3, rating_group: rating_groups[28] },
  { title: 'not responsive (no switching, wrong breakpoints)',  value: -7, rating_group: rating_groups[28] },
  { title: 'not perfectly responsive',                          value: -2, rating_group: rating_groups[28] },
  { title: 'global-nav list not horizontal or bullets visible', value: -2, rating_group: rating_groups[28] },
  { title: 'figure caption not beneath or visible in narrow',   value: -2, rating_group: rating_groups[28] },
  { title: 'body text not Comic Sans MS, fantasy',              value: -2, rating_group: rating_groups[28] },
  { title: 'not brighter colors',                               value: -2, rating_group: rating_groups[28] },
  { title: 'fails css validator',                               value: -7, rating_group: rating_groups[28] },
]






VariablePointsDeductionRating.create! [
  { title: 'correct answers', min_value: 0, max_value: 10, multiplication_factor: 4.0, rating_group: rating_groups[30] },
]






VariablePointsDeductionRating.create! [
  { title: 'misc. bonus', min_value: 0, max_value: 10, rating_group: rating_groups[3] },
  { title: 'misc. bonus', min_value: 0, max_value: 10, rating_group: rating_groups[8] },
  { title: 'misc. bonus', min_value: 0, max_value: 10, rating_group: rating_groups[10] },
  { title: 'misc. bonus', min_value: 0, max_value: 10, rating_group: rating_groups[15] },
  { title: 'misc. bonus', min_value: 0, max_value: 10, rating_group: rating_groups[24] },
  { title: 'misc. bonus', min_value: 0, max_value: 10, rating_group: rating_groups[29] },
  { title: 'misc. bonus', min_value: 0, max_value: 10, rating_group: rating_groups[31] },
]

VariablePointsDeductionRating.create! [
  { title: 'misc. subtractions', min_value: -10, max_value: 0, rating_group: rating_groups[3] },
  { title: 'misc. subtractions', min_value: -10, max_value: 0, rating_group: rating_groups[8] },
  { title: 'misc. subtractions', min_value: -10, max_value: 0, rating_group: rating_groups[10] },
  { title: 'misc. subtractions', min_value: -10, max_value: 0, rating_group: rating_groups[15] },
  { title: 'misc. subtractions', min_value: -10, max_value: 0, rating_group: rating_groups[24] },
  { title: 'misc. subtractions', min_value: -10, max_value: 0, rating_group: rating_groups[29] },
  { title: 'misc. subtractions', min_value: -10, max_value: 0, rating_group: rating_groups[31] },
]

FixedPercentageDeductionRating.create! [
  { title: '48h late deadline', value: -50, rating_group: rating_groups[3] },
  { title: '48h late deadline', value: -50, rating_group: rating_groups[8] },
  { title: '48h late deadline', value: -50, rating_group: rating_groups[10] },
  { title: '48h late deadline', value: -50, rating_group: rating_groups[15] },
  { title: '48h late deadline', value: -50, rating_group: rating_groups[24] },
  { title: '48h late deadline', value: -50, rating_group: rating_groups[29] },
  { title: '48h late deadline', value: -50, rating_group: rating_groups[31] },
]

PlagiarismRating.create! [
  { rating_group: rating_groups[3] },
  { rating_group: rating_groups[8] },
  { rating_group: rating_groups[10] },
  { rating_group: rating_groups[15] },
  { rating_group: rating_groups[24] },
  { rating_group: rating_groups[29] },
  { rating_group: rating_groups[31] },
]



Rating.all.map{ |obj| obj.row_order_position = :last; obj.save }
