class ExcelSpreadsheetExport < Export
  prop_accessor :summary, :exercises, :student_overview

  include ZipGeneration

  def perform!
    raise ExportError unless persisted?

    Dir.mktmpdir do |dir|
      generate_spreadsheets!(dir)
      generate_zip_and_assign_to_file!(dir)
    end
  end

  include PointsOverviewHelper
  include RatingsHelper

  private
  LIGHT_RED_COLOR = 63
  RED_COLOR = 62
  BLACK_COLOR = 8
  BORDER_THICKNESS = 2
  LIGHT_GREEN_COLOR = 61

  def generate_spreadsheets!(dir)
    term.tutorial_groups.each do |tutorial_group|
      generate_spreadsheet!(tutorial_group, dir)
    end
  end

  def summary?
    summary == "1"
  end

  def exercises?
    exercises == "1"
  end

  def student_overview?
    student_overview == "1"
  end

  def generate_spreadsheet!(tutorial_group, directory)
    workbook = WriteExcel.new(File.join(directory, xls_filename(tutorial_group)))
    styles = setup_workbook(workbook)

    term_registrations = tutorial_group.student_term_registrations.includes(:account, :exercise_registrations).order {account.forename} .order {account.surname}

    if summary?
      add_summary(workbook, styles, term_registrations)
    end

    if exercises?
      term.exercises.includes(rating_groups: :ratings).each do |exercise|
        add_exercise(workbook, styles, tutorial_group, term_registrations, exercise)
      end
    end

    if student_overview?
      add_student_overview(workbook, styles, tutorial_group, term_registrations)
    end

    workbook.close
  end

  def xls_filename(tutorial_group)
    parts = []

    parts << term.course.title
    parts << tutorial_group.title

    tutorial_group.tutor_term_registrations.includes(:account).each do |term_registration|
      parts << term_registration.account.forename
    end


    "#{parts.join("-").downcase.parameterize}.xls"
  end

  def setup_workbook(workbook)
    styles = Hash.new

    workbook.set_custom_color(LIGHT_RED_COLOR, 249, 135, 136)
    workbook.set_custom_color(RED_COLOR, 249, 108, 108)
    workbook.set_custom_color(LIGHT_GREEN_COLOR, 243, 240, 191)

    title_row_attrs = {bold: 1, font_size: 14}
    styles[:title_row] = workbook.add_format title_row_attrs
    styles[:title_row_left] = workbook.add_format title_row_attrs.merge({left: BORDER_THICKNESS, left_color: BLACK_COLOR})
    styles[:title_row_underlined] = workbook.add_format title_row_attrs.merge({bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR})

    summary_flipped_title_attrs = {rotation: 90, bg_color: "silver", align: "center"}
    styles[:summary_flipped_title] = workbook.add_format summary_flipped_title_attrs
    styles[:summary_flipped_title_underlined] = workbook.add_format summary_flipped_title_attrs.merge({bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR})

    styles[:flipped_title] = workbook.add_format rotation: 90, align: "center"
    styles[:title_cell] = workbook.add_format align: "center"
    styles[:title_cell_underlined] = workbook.add_format align: "center", bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR

    summary_title_cell_attrs = {bg_color: "silver", align: "center"}
    styles[:summary_title_cell] = workbook.add_format summary_title_cell_attrs
    styles[:summary_title_cell_underlined] = workbook.add_format summary_title_cell_attrs.merge({bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR})

    styles[:result_cell] = workbook.add_format bg_color: LIGHT_RED_COLOR, align: "center"

    styles[:total_points_title] = workbook.add_format bold: 1, top: BORDER_THICKNESS, top_color: BLACK_COLOR
    styles[:total_points_cell] = workbook.add_format align: "center", bold: 1, bg_color: RED_COLOR, top: BORDER_THICKNESS, top_color: BLACK_COLOR

    styles[:grade_title] = workbook.add_format bold: 1
    styles[:grade_cell] = workbook.add_format align: "center", bold: 1, bg_color: RED_COLOR

    styles[:exercise_title_cell] = workbook.add_format bold: 1, font_size: 20,
      align: "center", valign: "vcenter",
      bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR,
      left: BORDER_THICKNESS, left_color: BLACK_COLOR

    styles[:rating_group_title_cell] = workbook.add_format bold: 1, top: BORDER_THICKNESS, top_color: BLACK_COLOR
    styles[:rating_group_points_cell] = workbook.add_format bold: 1, align: "center", top: BORDER_THICKNESS, top_color: BLACK_COLOR, right: BORDER_THICKNESS, right_color: BLACK_COLOR
    styles[:student_rating_group_points_cell] = workbook.add_format bold: 1, align: "center", bg_color: LIGHT_RED_COLOR, top: BORDER_THICKNESS, top_color: BLACK_COLOR

    styles[:rating_title_cell] = workbook.add_format align: "left"
    styles[:rating_points_cell] = workbook.add_format align: "center", right: BORDER_THICKNESS, right_color: BLACK_COLOR
    styles[:evaluation_cell] = workbook.add_format align: "center", bg_color: LIGHT_GREEN_COLOR

    styles[:exercise_points_cell] = workbook.add_format align: "center", bold: 1, font_size: 16, bg_color: RED_COLOR, top: BORDER_THICKNESS, top_color: BLACK_COLOR
    styles[:exercise_points_title_cell] = workbook.add_format align: "right", bold: 1, font_size: 16, top: BORDER_THICKNESS, top_color: BLACK_COLOR, right: BORDER_THICKNESS, right_color: BLACK_COLOR

    styles[:student_overview_title] =  workbook.add_format align: "center", bold: 1, bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR

    styles
  end

  def add_summary(workbook, styles, term_registrations)
    students = term_registrations.map(&:account)

    grading_scale = GradingScaleService.new(term, term_registrations)

    worksheet = workbook.add_worksheet("summary")
    worksheet.set_column 0,0, 20
    worksheet.set_column 1, students.count, 4

    worksheet.write 0, 0, "Matrikelnr.", styles[:title_row]
    worksheet.write_row 0, 1, students.map {|student| student.matriculation_number}, styles[:summary_flipped_title]

    worksheet.write 1, 0, "sbox-alias", styles[:title_row]
    worksheet.write_row 1, 1, students.map {|student| sbox_alias(student)}, styles[:summary_flipped_title]

    worksheet.write 2, 0, "Vorname", styles[:title_row]
    worksheet.write_row 2, 1, students.map {|student| student.forename}, styles[:summary_flipped_title]

    worksheet.write 3, 0, "Nachname", styles[:title_row_underlined]
    worksheet.write_row 3, 1, students.map {|student| student.surname}, styles[:summary_flipped_title_underlined]

    term.exercises.each_with_index do |exercise, index|
      results = []

      term_registrations.each do |term_registration|
        results << exercise_result(term_registration, exercise)
      end

      worksheet_row = index + 4

      worksheet.write worksheet_row, 0, "#{index + 1} #{exercise.title}", styles[:title_row_left]
      worksheet.write_row worksheet_row, 1, results, styles[:result_cell]
    end

    row_index = term.exercises.count + 3
    worksheet.write row_index, 0, "total points", styles[:total_points_title]
    worksheet.write_row row_index, 1, term_registrations.map(&:points), styles[:total_points_cell]

    row_index += 1
    worksheet.write row_index, 0, "grade", styles[:grade_title]
    worksheet.write_row row_index, 1, term_registrations.map {|tr| grading_scale.grade_for_term_registration(tr)} , styles[:grade_cell]

    row_index += 2

    # setting row heights
    worksheet.set_row 0, 50
    worksheet.set_row 1, 100
    worksheet.set_row 2, 100
    worksheet.set_row 3, 100

    worksheet
  end

  def add_exercise(workbook, styles, tutorial_group, term_registrations, exercise)
    students = term_registrations.map(&:account)

    worksheet = workbook.add_worksheet(exercise.title.gsub(/[^A-Za-z0-9\ ]/, ""))
    worksheet.merge_range 0,0,1,1, exercise.title, styles[:exercise_title_cell]

    worksheet.write_row 0, 2, students.map {|s| "#{s.surname} #{s.forename}" }, styles[:flipped_title]
    worksheet.write_row 1, 2, (1..students.length).to_a, styles[:title_cell_underlined]

    # stud_rat_ev[student][rating] =~ ("x" | \d)
    stud_rat_ev = Hash.new {|h,k| h[k] = Hash.new  }

    # stud_rg_eg[student][rating_group] =~ \d
    stud_rg_eg = Hash.new {|h,k| h[k] = Hash.new }

    # stud_results[student] =~ \d
    stud_results = Hash.new

    exercise.submissions.for_tutorial_group(tutorial_group).includes(exercise_registrations: {term_registration: :account},
    submission_evaluation: {evaluation_groups: [:rating_group, evaluations: :rating]}).each do |sub|
      se = sub.submission_evaluation

      sub.exercise_registrations.each do |exercise_registration|
        student = exercise_registration.term_registration.account

        stud_results[student] = exercise_registration.points

        se.evaluation_groups.each do |eg|
          stud_rg_eg[student][eg.rating_group] = eg.points

          eg.evaluations.each do |ev|
            stud_rat_ev[student][ev.rating] = if ev.is_a? BinaryEvaluation
              if ev.value.to_i == 1
               "x"
              else
               ""
              end
            else
              ev.value || ""
            end
          end
        end
      end
    end

    row_index = 2
    exercise.rating_groups.each do |rating_group|
      worksheet.write(row_index, 0, rating_group.title, styles[:rating_group_title_cell])
      worksheet.write(row_index, 1, rating_group.points, styles[:rating_group_points_cell])
      worksheet.write_row(row_index, 2, students.map {|s| stud_rg_eg[s][rating_group] || "-"}, styles[:student_rating_group_points_cell])
      row_index += 1

      rating_group.ratings.each do |rating|
        worksheet.write(row_index, 0, rating.title, styles[:rating_title_cell])
        worksheet.write(row_index, 1, rating_points_description(rating), styles[:rating_points_cell])
        worksheet.write_row(row_index, 2, students.map {|s| stud_rat_ev[s][rating] || "-"}, styles[:evaluation_cell])
        row_index += 1
      end
    end

    worksheet.merge_range(row_index, 0, row_index, 1, "Points reached", styles[:exercise_points_title_cell])
    worksheet.write_row(row_index, 2, students.map {|s| stud_results[s] || 0 }, styles[:exercise_points_cell])

    worksheet.set_column 0,0, 30
    worksheet.set_column 1,1, 7
    worksheet.set_column 2, (students.count+1), 4

    worksheet
  end

  def add_student_overview(workbook, styles, tutorial_group, term_registrations)
    students = term_registrations.map(&:account)

    worksheet = workbook.add_worksheet("students")
    row_index = 0
    worksheet.set_column 1, 3, 20
    worksheet.set_column 4, 6, 40

    worksheet.write_row row_index, 0, ["Gruppe", "Familienname", "Vorname", "Matrikelnummer", "E-Mail", "Username", "TUG Student Website"], styles[:student_overview_title]
    row_index += 1

    students.each_with_index do |student, index|
      username = sbox_alias(student)
      website = "www.student.tugraz.at/#{username}"

      worksheet.write_row row_index, 0, ["#{tutorial_group.title} #{index + 1}", student.surname, student.forename, student.matriculation_number, student.email, username, website]
      row_index += 1
    end

    worksheet
  end

  def sbox_alias(student)
    student.email.gsub(/@.*$/, "")
  end
end
