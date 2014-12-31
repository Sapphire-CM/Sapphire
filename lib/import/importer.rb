module Import::Importer
  def smart_guess_new_import_mapping
    # guess mapping from content
    row = values.first
    row.each_index do |cell_index|

      if /\A(T|G)[\d]{1}/ =~ row[cell_index]
        import_mapping.group ||= cell_index
        next
      end

      if /.+@.+\..+/ =~ row[cell_index]
        import_mapping.email ||= cell_index
        next
      end

      if /\A[\d]{7}\z/ =~ row[cell_index]
        import_mapping.matriculation_number ||= cell_index
        next
      end
    end if values.any?

    # hard coded values of headers
    headers.each_index do |cell_index|
      if /.*Vorname.*/ =~ headers[cell_index]
        import_mapping.forename ||= cell_index
        next
      end

      if /.*Nachname.*/ =~ headers[cell_index]
        import_mapping.surname ||= cell_index
        next
      end

      if /.*Anmerkung.*/ =~ headers[cell_index]
        import_mapping.comment ||= cell_index
        next
      end
    end if headers

    import_mapping.save!
  end

  def import!
    import_result.update! processed_rows: 0, total_rows: values.length

    values.each do |row|
      import_result.increment! :processed_rows

      account = create_student_account row
      group_title = row[import_mapping.group.to_i]
      student_group_title = []

      case import_options.matching_groups.to_sym
      when :first_match
        regexp = Regexp.new import_options.tutorial_groups_regexp
        m = regexp.match group_title

        tutorial_group = create_tutorial_group "T#{m[:tutorial]}"
        create_term_registration row, account, tutorial_group
      when :both_matches
        regexp = Regexp.new import_options.student_groups_regexp
        m = regexp.match group_title

        tutorial_group = create_tutorial_group "T#{m[:tutorial]}"

        student_group = create_student_group group_title, false, tutorial_group
        term_registration create_term_registration row, account, tutorial_group

        # TODO: add student to student_group
      else
        raise "ImportOption matching_groups: #{import_options.matching_groups}" # unknown value for :matching_groups
      end
    end
  end

  private

  def create_student_account(row)
    student = Account.find_or_initialize_by(matriculation_number: row[import_mapping.matriculation_number.to_i])
    student.forename = row[import_mapping.forename.to_i]
    student.surname = row[import_mapping.surname.to_i]
    student.email = row[import_mapping.email.to_i]

    student.password = student.default_password if student.new_record?

    new_record = student.new_record?
    if student.save
      import_result.imported_students += 1 if new_record
    else
      import_result.success = false
      create_problem_definition row, student.errors.full_messages
    end

    import_result.save!

    student
  end

  def create_tutorial_group(title)
    tutorial_group = import.term.tutorial_groups.find_or_initialize_by(title: title)

    new_record = tutorial_group.new_record?
    if tutorial_group.save
      import_result.imported_tutorial_groups += 1 if new_record
    else
      import_result.success = false
      create_problem_definition row, tutorial_group.errors.full_messages
    end

    import_result.save!

    tutorial_group
  end

  def create_term_registration(row, account, tutorial_group)
    term_registration = TermRegistration.where(account: account, tutorial_group: tutorial_group).first_or_initialize(term_id: tutorial_group.term.id)
    term_registration.role = TermRegistration::STUDENT

    new_record = term_registration.new_record?
    if term_registration.save
      if new_record
        import_result.imported_term_registrations += 1
        NotificationJob.welcome_notification term_registration
      end
    else
      import_result.success = false
      create_problem_definition row, term_registration.errors.full_messages
    end

    import_result.save!

    term_registration
  end

  def create_student_group(title, solitary, tutorial_group)
    student_group = tutorial_group.student_groups.find_or_initialize_by(title: title)
    student_group.solitary = solitary

    new_record = student_group.new_record?
    if student_group.save
      import_result.imported_student_groups += 1 if new_record
    else
      import_result.success = false
      create_problem_definition row, student_group.errors.full_messages
    end

    import_result.save!

    student_group
  end

  def create_student_registration(row, student, student_group, tutorial_group)
    all_students = tutorial_group.student_groups.flat_map{ |sg| sg.students }
    if !all_students.empty? && all_students.include?(student)
      registration = student_group.student_registrations.find_or_initialize_by(account_id: student.id)
    else
      registration = student_group.student_registrations.new
      registration.student = student
    end

    registration.comment = row[import_mapping.comment.to_i] if import_mapping.comment

    new_record = registration.new_record?
    if registration.save
      import_result.imported_student_registrations += 1 if new_record
    else
      import_result.success = false
      create_problem_definition row, registration.errors.full_messages
    end

    import_result.save!

    registration
  end

  def create_problem_definition(row, full_messages)
    entry = {
      group: row[import_mapping.group.to_i],
      matriculation_number: row[import_mapping.matriculation_number.to_i],
      forename: row[import_mapping.forename.to_i],
      surname: row[import_mapping.surname.to_i],
      email: row[import_mapping.email.to_i],
      comment: row[import_mapping.comment.to_i]
    }

    import_result.import_errors.create row: row.to_s, entry: entry.to_s, message: full_messages.to_s
  end
end
