module ExerciseEvaluationsTableHelper
  def exercise_evaluations_table(table_data)
    unless table_data.transpose
      render "table_ratings_students", data: table_data
    else
      render "table_students_ratings", data: table_data
    end
  end

  def exercise_evaluations_view_dropdown(data)
    links = []

    if data.exercise.group_submission?
      links << link_to("Group Name", '#', data:{:"cycle-control" => {selector: exercise_evaluations_title_cycle_group, cycle_to: "group_name"}})
      links << link_to("Student Count", '#', data:{:"cycle-control" => {selector: exercise_evaluations_title_cycle_group, cycle_to: "student_count"}})
    else
      links << link_to("Fullname", '#', data:{:"cycle-control" => {selector: exercise_evaluations_title_cycle_group, cycle_to: "fullname"}})
      links << link_to("Email", '#', data:{:"cycle-control" => {selector: exercise_evaluations_title_cycle_group, cycle_to: "email"}})
      links << link_to("Matriculum Number", '#', data:{:"cycle-control" => {selector: exercise_evaluations_title_cycle_group, cycle_to: "matriculum_number"}})
    end

    dropdown_button("View", links)
  end

  def exercise_evaluations_student_group_title(data, student_group)
    titles = Hash.new
    if data.exercise.group_submission?
      titles[:group_name] = student_group.title
      titles[:student_count] = pluralize(student_group.students.count, "student")
    else
      student = student_group.students.first
      titles[:fullname] = student.fullname
      titles[:email]= student.email
      titles[:matriculum_number] = student.matriculum_number
    end

    options = {data: {cycle: titles.to_json}, class: "evaluations-table-cycle"}
    state = exercise_evaluations_state(data, student_group)

    if state != :present
      options[:data][:tooltip] = ""
      options[:title] = if state == :not_evaluated
        "Submission hasn't been evaluated"
      else
        "No submission present"
      end
    end

    content_tag :span, titles[titles.keys.first], options
  end

  def exercise_evaluations_state_class(data, student_group)
    case exercise_evaluations_state(data, student_group)
    when :present then "submission-evaluation-state-present"
    when :not_evaluated then "submission-evaluation-state-not-evaluated"
    when :missing then "submission-evaluation-state-missing"
    end
  end



  # only use in submission_evaluation table - submissions have to be prepaired
  def exercise_evaluations_table_form(data, student_group, rating)
    if s = data.submission_for_student_group(student_group)
      exercise_evaluations_form(data, student_group, rating)
    else
      # what to do if no submission present?
      "-"
    end

  end

  def exercise_evaluations_result_id(student_group)
    "exercise-evaluations-result-#{student_group.id}"
  end

  def exercise_evaluations_submission_result(data, student_group)
    s = data.submission_for_student_group(student_group)
    content = if s && s.evaluated?
      s.submission_evaluation.evaluation_result
    else
      "n/a"
    end

    content_tag :span, content
  end

  def exercise_evaluations_evaluation_group_result(data, student_group, rating_group)
    if eg = data.evaluation_group_for_student_group_and_rating_group(student_group, rating_group)
      eg.points
    else
      "-"
    end
  end

  def exercise_evaluations_evaluation_group_results_id(student_group, rating_group)
    "evaluation-group-#{student_group.id}-#{rating_group.id}"
  end

  private
  def exercise_evaluations_form(data, student_group, rating)
    evaluation = data.evaluation_for_student_group_and_rating(student_group, rating) || Evaluation.new_from_rating(rating)
    submission = data.submission_for_student_group(student_group)

    url = term_exercise_evaluation_path(current_term, @exercise, format: :js)
    html_options = {class: "exercise-evaluations-table-form", id: exercise_evaluations_form_id(student_group, rating)}

    simple_form_for(evaluation, as: :evaluation, url: url, html: html_options, remote: true) do |f|
      rc = ""
      rc << evaluation_input_field(f)
      rc << hidden_field_tag(:submission_id, submission.id)
      rc << hidden_field_tag(:evaluation_id, evaluation.id)
      rc << hidden_field_tag(:rating_id,     rating.id)
      rc.html_safe
    end
  end

  def exercise_evaluations_form_id(student_group, rating)
    "submission-evaluations-#{student_group.id}-#{rating.id}"
  end

  def exercise_evaluations_state(data, student_group)
    if s = data.submission_for_student_group(student_group)
      if s.evaluated?
        :present
      else
        :not_evaluated
      end
    else
      :missing
    end
  end

  def exercise_evaluations_title_cycle_group
    "evaluations-table-cycle"
  end
end
