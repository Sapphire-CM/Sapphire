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
    import_result.update! success: true, processed_rows: 0, total_rows: values.length

    values.each do |row|
      import_result.increment! :processed_rows

      group_title = row[import_mapping.group.to_i]

      matcher = import_options.matching_groups.to_sym == :first_match ? 'tutorial' : 'student'
      regexp = Regexp.new import_options.send("#{matcher}_groups_regexp")
      m = regexp.match group_title

      unless m.present? && m.names.map(&:to_sym).include?(:tutorial) && m[:tutorial].present?
        import_result.update! success: false
        create_problem_definition row, "regexp did not match: #{group_title} - #{regexp}"
        next
      end

      account = create_student_account row
      tutorial_group = create_tutorial_group m[:tutorial]
      term_registration = create_term_registration row, account, tutorial_group

      if import_options.matching_groups.to_sym == :both_matches
        student_group = create_student_group group_title, tutorial_group
        term_registration.update! student_group: student_group
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
      import_result.imported_term_registrations += 1 if new_record
      NotificationJob.welcome_notification(term_registration) if import_options.send_welcome_notifications
    else
      import_result.success = false
      create_problem_definition row, term_registration.errors.full_messages
    end

    import_result.save!

    term_registration
  end

  def create_student_group(title, tutorial_group)
    student_group = tutorial_group.student_groups.find_or_initialize_by(title: title)

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
