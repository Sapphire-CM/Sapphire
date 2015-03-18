class ExcelSpreadsheetExport < Export
  include ZipGeneration
  include TutorsHelper
  include TutorialGroupsHelper

  prop_accessor :summary, :exercises, :student_overview

  validate do
    unless summary? || exercises? || student_overview?
      errors.add(:base, 'nothing to export')
    end
  end

  def perform!
    raise ExportError unless persisted?

    Dir.mktmpdir do |dir|
      generate_spreadsheets!(dir)
      generate_zip_and_assign_to_file!(dir)
    end
  end

  include PointsOverviewHelper
  include RatingsHelper
  include ActiveSupport::NumberHelper

  private

  BLACK_COLOR = 8
  SILVER_COLOR = 22
  RED_COLOR = 62
  LIGHT_GREEN_COLOR = 61
  LIGHT_RED_COLOR = 63

  BORDER_THICKNESS = 2

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

    term_registrations = tutorial_group.student_term_registrations
      .includes(:account, :exercise_registrations)
      .references(:account)
      .order{ account.surname.asc }
      .order{ account.forename.asc }


    if summary?
      add_student_group_summary(workbook, styles, tutorial_group, term_registrations) if term.group_submissions?
      add_student_summary(workbook, styles, tutorial_group, term_registrations)
    end

    if exercises?
      term.exercises.each do |exercise|
        if exercise.group_submission?
          add_group_exercise(workbook, styles, tutorial_group, term_registrations, exercise)
        else
          add_solitary_exercise(workbook, styles, tutorial_group, term_registrations, exercise)
        end
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
    parts << term.title
    parts << tutorial_group.title

    tutorial_group.tutor_term_registrations.includes(:account).each do |term_registration|
      parts << term_registration.account.forename
    end

    "#{parts.join("-").downcase.parameterize}.xls"
  end

  def reset_row
    @row_index = 0
  end

  def next_row
    @row_index += 1
  end

  def same_row
    @row_index
  end

  def setup_workbook(workbook)
    styles = Hash.new

    workbook.set_custom_color(SILVER_COLOR, 230, 230, 230)
    workbook.set_custom_color(RED_COLOR, 251, 149, 149)
    workbook.set_custom_color(LIGHT_GREEN_COLOR, 243, 240, 191)
    workbook.set_custom_color(LIGHT_RED_COLOR, 253, 207, 207)

    title_row_attrs = {bold: 1, font_size: 14}
    styles[:title_row] = workbook.add_format title_row_attrs
    styles[:title_row_left] = workbook.add_format title_row_attrs.merge({left: BORDER_THICKNESS, left_color: BLACK_COLOR})
    styles[:title_row_underlined] = workbook.add_format title_row_attrs.merge({bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR})

    summary_flipped_title_attrs = {rotation: 90, bg_color: SILVER_COLOR, align: "center"}
    styles[:summary_flipped_title] = workbook.add_format summary_flipped_title_attrs
    styles[:summary_flipped_title_underlined] = workbook.add_format summary_flipped_title_attrs.merge({bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR})

    styles[:flipped_title] = workbook.add_format rotation: 90, align: "center"
    styles[:title_cell] = workbook.add_format align: "center"
    styles[:title_cell_underlined] = workbook.add_format align: "center", bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR

    summary_title_cell_attrs = {bg_color: SILVER_COLOR, align: "center"}
    styles[:summary_title_cell] = workbook.add_format summary_title_cell_attrs
    styles[:summary_title_cell_underlined] = workbook.add_format summary_title_cell_attrs.merge({bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR})

    styles[:result_cell] = workbook.add_format bg_color: LIGHT_RED_COLOR, align: "center"

    styles[:total_points_title] = workbook.add_format bold: 1, top: BORDER_THICKNESS, top_color: BLACK_COLOR
    styles[:total_points_cell] = workbook.add_format align: "center", bold: 1, bg_color: RED_COLOR, top: BORDER_THICKNESS, top_color: BLACK_COLOR

    styles[:grade_title] = workbook.add_format bold: 1
    styles[:grade_cell] = workbook.add_format align: "center", bold: 1, bg_color: RED_COLOR

    grading_scale_title_cell_attrs = {bg_color: RED_COLOR, align: "center", bold: 1, top: BORDER_THICKNESS, top_color: BLACK_COLOR, bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR}
    styles[:grading_scale_title] = workbook.add_format grading_scale_title_cell_attrs
    styles[:grading_scale_title_first] = workbook.add_format grading_scale_title_cell_attrs.merge({left: BORDER_THICKNESS, left_color: BLACK_COLOR})
    styles[:grading_scale_title_last] = workbook.add_format grading_scale_title_cell_attrs.merge({right: BORDER_THICKNESS, right_color: BLACK_COLOR})

    styles[:grading_scale_grade_title] = workbook.add_format({bold: 1, bg_color: LIGHT_GREEN_COLOR, left: BORDER_THICKNESS, left_color: BLACK_COLOR})

    grading_scale_footer_cell_attrs = {bg_color: RED_COLOR, bold: 1, top: BORDER_THICKNESS, top_color: BLACK_COLOR}
    styles[:grading_scale_sum_title] = workbook.add_format grading_scale_footer_cell_attrs.merge({left: BORDER_THICKNESS, left_color: BLACK_COLOR})
    styles[:grading_scale_sum_inner] = workbook.add_format grading_scale_footer_cell_attrs
    styles[:grading_scale_sum_inner_last] = workbook.add_format grading_scale_footer_cell_attrs.merge(right: BORDER_THICKNESS, right_color: BLACK_COLOR)

    grading_scale_footer_last_row_cell_attrs = grading_scale_footer_cell_attrs.merge({bottom: BORDER_THICKNESS, bottom_color: BLACK_COLOR})
    styles[:grading_scale_footer_title] = workbook.add_format grading_scale_footer_last_row_cell_attrs.merge({left: BORDER_THICKNESS, left_color: BLACK_COLOR})
    styles[:grading_scale_footer_inner] = workbook.add_format grading_scale_footer_last_row_cell_attrs
    styles[:grading_scale_footer_inner_last] = workbook.add_format grading_scale_footer_last_row_cell_attrs.merge({right: BORDER_THICKNESS, right_color: BLACK_COLOR})

    grading_scale_inner = {bg_color: SILVER_COLOR, align: "right"}
    styles[:grading_scale_inner] = workbook.add_format grading_scale_inner
    styles[:grading_scale_inner_last] = workbook.add_format grading_scale_inner.merge({right: BORDER_THICKNESS, left: BLACK_COLOR})

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

  def add_student_group_summary(workbook, styles, tutorial_group, term_registrations)
    student_groups = tutorial_group.student_groups.order(:title)

    grading_scale = term.grading_scale(term_registrations)

    worksheet = workbook.add_worksheet("group summary")

    # set column widths
    worksheet.set_column 0, 0, 20
    worksheet.set_column 1, student_groups.count, 4

    # set row heights
    worksheet.set_row 0, 50
    worksheet.set_row 1, 50
    worksheet.set_row 2, 100

    reset_row

    worksheet.write same_row, 0, "#{term.course.title} #{term.title} - #{tutorial_group_title tutorial_group}", styles[:title_row]

    next_row

    worksheet.write next_row, 0, "Student Group", styles[:title_row_underlined]
    worksheet.write_row same_row, 1, student_groups.map {|student_group| student_group.title}, styles[:summary_flipped_title_underlined]

    term.exercises.group_exercises.each_with_index do |exercise, index|
      results = []

      student_groups.each do |student_group|
        submission = student_group.submissions.find_by(exercise: exercise)

        results << if submission.present?
          submission.submission_evaluation.evaluation_result
        else
          "na"
        end
      end

      worksheet_row = index + 4

      worksheet.write next_row, 0, "#{index + 1} #{exercise.title}", styles[:title_row_left]
      worksheet.write_row same_row, 1, results, styles[:result_cell]
    end

    worksheet.write next_row, 0, "total points", styles[:total_points_title]
    worksheet.write_row same_row, 1, student_groups.map(&:points), styles[:total_points_cell]

    worksheet.write next_row, 0, "average grade", styles[:grade_title]
    worksheet.write_row same_row, 1, student_groups.map {|student_group| grading_scale.average_grade_for_student_group(student_group) }, styles[:grade_cell]
  end

  def add_student_summary(workbook, styles, tutorial_group, term_registrations)
    students = term_registrations.map(&:account)

    grading_scale = term.grading_scale(term_registrations)

    worksheet = workbook.add_worksheet("summary")

    # set column widths
    worksheet.set_column 0, 0, 20
    worksheet.set_column 1, students.count, 4

    # set row heights
    worksheet.set_row 0, 50
    worksheet.set_row 1, 50
    worksheet.set_row 2, 100
    worksheet.set_row 3, 100
    worksheet.set_row 4, 100
    worksheet.set_row 5, 100

    reset_row

    worksheet.write same_row, 0, "#{term.course.title} #{term.title} - #{tutorial_group_title tutorial_group}", styles[:title_row]

    next_row

    worksheet.write next_row, 0, "Matrikelnr.", styles[:title_row]
    worksheet.write_row same_row, 1, students.map {|student| student.matriculation_number}, styles[:summary_flipped_title]

    worksheet.write next_row, 0, "sbox-alias", styles[:title_row]
    worksheet.write_row same_row, 1, students.map {|student| sbox_alias(student)}, styles[:summary_flipped_title]

    worksheet.write next_row, 0, "Vorname", styles[:title_row]
    worksheet.write_row same_row, 1, students.map {|student| student.forename}, styles[:summary_flipped_title]

    worksheet.write next_row, 0, "Nachname", styles[:title_row_underlined]
    worksheet.write_row same_row, 1, students.map {|student| student.surname}, styles[:summary_flipped_title_underlined]

    term.exercises.each_with_index do |exercise, index|
      results = []

      term_registrations.each do |term_registration|
        results << exercise_result(term_registration, exercise)
      end

      worksheet_row = index + 4

      worksheet.write next_row, 0, "#{index + 1} #{exercise.title}", styles[:title_row_left]
      worksheet.write_row same_row, 1, results, styles[:result_cell]
    end

    worksheet.write next_row, 0, "total points", styles[:total_points_title]
    worksheet.write_row same_row, 1, term_registrations.map(&:points), styles[:total_points_cell]

    worksheet.write next_row, 0, "grade", styles[:grade_title]
    worksheet.write_row same_row, 1, term_registrations.map {|tr| grading_scale.grade_for_term_registration(tr)} , styles[:grade_cell]

    next_row

    worksheet.merge_range next_row, 1, same_row, 2, "Grade", styles[:grading_scale_title_first]
    worksheet.merge_range same_row, 3, same_row, 4, "Points", styles[:grading_scale_title]
    worksheet.merge_range same_row, 5, same_row, 6, "Students", styles[:grading_scale_title]
    worksheet.merge_range same_row, 7, same_row, 8, "Percent", styles[:grading_scale_title_last]

    grading_scale.grading_ranges.each do |grading_range|
      worksheet.merge_range next_row, 1, same_row, 2, grading_range.grade, styles[:grading_scale_grade_title]
      worksheet.merge_range same_row, 3, same_row, 4, "#{grading_range.minimum_points} - #{grading_range.maximum_ui_points}", styles[:grading_scale_inner]
      worksheet.merge_range same_row, 5, same_row, 6, grading_range.student_count, styles[:grading_scale_inner]
      worksheet.merge_range same_row, 7, same_row, 8, number_to_percentage(grading_scale.percent_for(grading_range.grade), precision: 1), styles[:grading_scale_inner_last]
    end

    worksheet.merge_range next_row, 1, same_row, 2, "Sum", styles[:grading_scale_sum_title]
    worksheet.merge_range same_row, 3, same_row, 4, "", styles[:grading_scale_sum_inner]
    worksheet.merge_range same_row, 5, same_row, 6, grading_scale.graded_count, styles[:grading_scale_sum_inner]
    worksheet.merge_range same_row, 7, same_row, 8, '', styles[:grading_scale_sum_inner_last]

    worksheet.merge_range next_row, 1, same_row, 2, "Ungraded", styles[:grading_scale_footer_title]
    worksheet.merge_range same_row, 3, same_row, 4, "", styles[:grading_scale_footer_inner]
    worksheet.merge_range same_row, 5, same_row, 6, grading_scale.ungraded_count, styles[:grading_scale_footer_inner]
    worksheet.merge_range same_row, 7, same_row, 8, '', styles[:grading_scale_footer_inner_last]
    worksheet
  end

  def add_group_exercise(workbook, styles, tutorial_group, term_registrations, exercise)
    student_groups = tutorial_group.student_groups.order(:title)

    worksheet = workbook.add_worksheet(exercise.title.gsub(/[^A-Za-z0-9\ ]/, ""))
    worksheet.merge_range 0,0,1,1, exercise.title, styles[:exercise_title_cell]

    worksheet.write_row 0, 2, student_groups.map {|sg| sg.title }, styles[:flipped_title]
    worksheet.write_row 1, 2, (1..student_groups.length).to_a, styles[:title_cell_underlined]

    # stud_rat_ev[student][rating] =~ ("x" | \d)
    stud_rat_ev = Hash.new {|h,k| h[k] = Hash.new  }

    # stud_rg_eg[student][rating_group] =~ \d
    stud_rg_eg = Hash.new {|h,k| h[k] = Hash.new }

    # stud_results[student] =~ \d
    stud_results = Hash.new

    key_paths = [:student_group, {submission_evaluation: {evaluation_groups: [:rating_group, {evaluations: :rating}]}}]

    exercise.submissions.for_tutorial_group(tutorial_group).includes(key_paths).joins(key_paths).each do |sub|
      se = sub.submission_evaluation
      student_group = sub.student_group

      if student_group.present?
        stud_results[student_group] = se.evaluation_result

        se.evaluation_groups.each do |eg|
          stud_rg_eg[student_group][eg.rating_group] = eg.points

          eg.evaluations.each do |ev|
            stud_rat_ev[student_group][ev.rating] = if ev.is_a? BinaryEvaluation
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
    exercise.rating_groups.rank(:row_order).includes(:ratings).each do |rating_group|
      worksheet.write(row_index, 0, rating_group.title, styles[:rating_group_title_cell])
      worksheet.write(row_index, 1, rating_group.points, styles[:rating_group_points_cell])
      worksheet.write_row(row_index, 2, student_groups.map {|sg| stud_rg_eg[sg][rating_group] || "-"}, styles[:student_rating_group_points_cell])
      row_index += 1

      rating_group.ratings.each do |rating|
        worksheet.write(row_index, 0, rating.title, styles[:rating_title_cell])
        worksheet.write(row_index, 1, rating_points_description(rating), styles[:rating_points_cell])
        worksheet.write_row(row_index, 2, student_groups.map {|sg| stud_rat_ev[sg][rating] || "-"}, styles[:evaluation_cell])
        row_index += 1
      end
    end

    worksheet.merge_range(row_index, 0, row_index, 1, "Points reached", styles[:exercise_points_title_cell])
    worksheet.write_row(row_index, 2, student_groups.map {|sg| stud_results[sg] || 0 }, styles[:exercise_points_cell])

    worksheet.set_column 0,0, 30
    worksheet.set_column 1,1, 7
    worksheet.set_column 2, (student_groups.length+1), 4

    worksheet
  end

  def add_solitary_exercise(workbook, styles, tutorial_group, term_registrations, exercise)
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

    key_paths = {exercise_registrations: {term_registration: :account}, submission_evaluation: {evaluation_groups: [:rating_group, evaluations: :rating]}}

    exercise.submissions.for_tutorial_group(tutorial_group).includes(key_paths).joins(key_paths).each do |sub|
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
    exercise.rating_groups.rank(:row_order).includes(:ratings).each do |rating_group|
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
    worksheet = workbook.add_worksheet("students")
    row_index = 0
    worksheet.set_column 1, 3, 20
    worksheet.set_column 4, 6, 40


    worksheet.write_row row_index, 0, ["Gruppe", "Familienname", "Vorname", "Matrikelnummer", "E-Mail", "Username", "TUG Student Website"], styles[:student_overview_title]
    row_index += 1

    term_registrations.each_with_index do |term_registration, index|
      student = term_registration.account

      group_title = "#{tutorial_group.title} #{index + 1}"
      group_title << " - #{term_registration.student_group.title}" if term_registration.student_group.present?

      username = sbox_alias(student)
      website = "www.student.tugraz.at/#{username}"

      worksheet.write_row row_index, 0, [group_title, student.surname, student.forename, student.matriculation_number, student.email, username, website]
      row_index += 1
    end

    worksheet
  end

  def sbox_alias(student)
    student.email.gsub(/@.*$/, "")
  end
end
