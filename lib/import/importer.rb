module Import::Importer

  def smart_guess_new_import_mapping
    smart_guessed_import_mapping = Import::ImportMapping.new

    # guess mapping from content
    if values.any?
      row = values.first

      row.each_index do |cell_index|
        smart_guessed_import_mapping.group = cell_index if /\A(T|G)[\d]{1}/ =~ row[cell_index]
        smart_guessed_import_mapping.email = cell_index if /.*?@?.*/ =~ row[cell_index]
        smart_guessed_import_mapping.matriculum_number = cell_index if /\A[\d]{7}\z/ =~ row[cell_index]

        begin
          smart_guessed_import_mapping.registered_at = cell_index if row[cell_index].to_datetime
        rescue
        end
      end
    end

    # hard coded values of headers
    headers.each_index do |cell_index|
      smart_guessed_import_mapping.forename = cell_index if /.*Vorname.*/ =~ headers[cell_index]
      smart_guessed_import_mapping.surname = cell_index if /.*Nachname.*/ =~ headers[cell_index]
      smart_guessed_import_mapping.comment = cell_index if /.*Anmerkung.*/ =~ headers[cell_index]
    end if headers

    self.import_mapping = smart_guessed_import_mapping
    self.save
  end

  def import(params)
    @import_result = {
      success: true,
      imported_students: 0,
      imported_tutorial_groups: 0,
      imported_student_groups: 0,
      imported_student_registrations: 0,
      problems: []
    }

    if not update_attributes(params)
      @import_result[:success] = false
      return result
    end

    begin
      values.each do |row|
        student = create_student_account row


        group_title = row[import_mapping.group.to_i]

        case import_options[:matching_groups]
        when "first"
          regexp = Regexp.new(import_options[:tutorial_groups_regexp])
          m = regexp.match(group_title)
          tutorial_group_title = m[:tutorial]
          student_group_title = "#{student.matriculum_number}"
        when "both"
          regexp = Regexp.new(import_options[:student_groups_regexp])
          m = regexp.match(group_title)
          tutorial_group_title = m[:tutorial]
          student_group_title = m[:student]
        else
          raise # unknown value for :matching_groups
        end


        tutorial_group = create_tutorial_group "T#{tutorial_group_title}"
        student_group = create_student_group "G#{student_group_title}", tutorial_group
        create_student_registration row, student, student_group, tutorial_group
      end

      self.status = "imported"
      self.import_result = @import_result
      if not self.save
        @import_result[:success] = false
      end

    # TODO: uncomment me in production!
    # rescue
    #   puts $!
    #   @import_result[:success] = false
    end

    @import_result
  end




private

  def create_student_account(row)
    student = Account.find_or_initialize_by_matriculum_number(row[import_mapping.matriculum_number.to_i])
    student.forename = row[import_mapping.forename.to_i]
    student.surname = row[import_mapping.surname.to_i]
    student.email = row[import_mapping.email.to_i]

    # TODO: change default password
    student.password              = "123456"
    student.password_confirmation = "123456"

    if student.save
      @import_result[:imported_students] += 1
    else
      @import_result[:success] = false
      @import_result[:problems] << student
    end

    student
  end

  def create_tutorial_group(title)
    tutorial_group = term.tutorial_groups.find_or_initialize_by_title(title)

    if tutorial_group.save
      @import_result[:imported_tutorial_groups] += 1
    else
      @import_result[:success] = false
      @import_result[:problems] << tutorial_group
    end

    tutorial_group
  end

  def create_student_group(title, tutorial_group)
    student_group = tutorial_group.student_groups.find_or_initialize_by_title(title)

    if student_group.save
      @import_result[:imported_student_groups] += 1
    else
      @import_result[:success] = false
      @import_result[:problems] << student_group
    end

    student_group
  end

  def create_student_registration(row, student, student_group, tutorial_group)
    all_students = tutorial_group.student_groups.flat_map{ |sg| sg.students }
    if !all_students.empty? && all_students.include?(student)
      registration = student_group.student_registrations.find_or_initialize_by_account_id(student.id)
    else
      registration = student_group.student_registrations.new
      registration.student = student
    end

    registration.registered_at = row[import_mapping.registered_at.to_i].to_datetime
    registration.comment = row[import_mapping.comment.to_i] if import_mapping.comment

    if registration.save
      @import_result[:imported_student_registrations] += 1
    else
      @import_result[:success] = false
      @import_result[:problems] << registration
    end

    registration
  end

end
