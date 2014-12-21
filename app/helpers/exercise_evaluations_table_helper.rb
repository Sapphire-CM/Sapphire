module ExerciseEvaluationsTableHelper
  def exercise_evaluations_table(table_data)
    unless table_data.transpose
      render partial: "table_ratings_students", locals: {data: table_data}, formats: :html
    else
      render partial: "table_students_ratings", locals: {data: table_data}, formats: :html
    end
  end

  def exercise_evaluations_view_dropdown(exercise)
    links = []

    if exercise.group_submission?
      links << link_to("Group Name", '#', data:{:"cycle-control" => {selector: exercise_evaluations_title_cycle_group, cycle_to: "group_name"}})
      links << link_to("Student Count", '#', data:{:"cycle-control" => {selector: exercise_evaluations_title_cycle_group, cycle_to: "student_count"}})
    else
      links << link_to("Forename Surname", '#', data:{:"cycle-control" => {selector: exercise_evaluations_title_cycle_group, cycle_to: "forename_surname"}})
      links << link_to("Surname Forename", '#', data:{:"cycle-control" => {selector: exercise_evaluations_title_cycle_group, cycle_to: "surname_forename"}})
      links << link_to("Email", '#', data:{:"cycle-control" => {selector: exercise_evaluations_title_cycle_group, cycle_to: "email"}})
      links << link_to("Matriculation Number", '#', data:{:"cycle-control" => {selector: exercise_evaluations_title_cycle_group, cycle_to: "matriculation_number"}})
    end

    title = exercise.group_submission? ? "Groups" : "Students"
    dropdown_button(title, links)
  end

  def exercise_evaluations_order_dropdown(exercise)
    links = []

    if exercise.group_submission?
      links << link_to("Group Name", '#', data: {order: 'group_name'})
      links << link_to("Group Name (inverse)", '#', data: {order: 'group_name_inverse'})
    else
      links << link_to("Surname Forename", '#', data: {order: 'surname_forename'})
      links << link_to("Matriculation Number", '#', data: {order: 'matriculation_number'})
      links << link_to("Email", '#', data: {order: 'email'})
      links << link_to("Surname Forename (inverse)", '#', data: {order: 'surname_forename_inverse'})
      links << link_to("Matriculation Number (inverse)", '#', data: {order: 'matriculation_number_inverse'})
      links << link_to("Email (inverse)", '#', data: {order: 'email_inverse'})
    end

    dropdown_button("Order", links, dropdown_class: "orders_dropdown")
  end

  def exercise_evaluations_tutorial_groups_dropdown(tutorial_groups)
    links = tutorial_groups.map do |tutorial_group|
      link_to tutorial_group_title(tutorial_group), '#', data: {tutorial_group_id: tutorial_group.id}
    end
    dropdown_button("Tutorial Group", links, dropdown_class: "tutorial_groups_dropdown")
  end


  def exercise_evaluations_student_group_title(data, student_group)
    titles = Hash.new
    if data.exercise.group_submission?
      titles[:group_name] = student_group.title
      titles[:student_count] = pluralize(student_group.students.count, "student")
    else
      student = student_group.students.first
      titles[:forename_surname] = student.fullname
      titles[:surname_forename] = "#{student.surname} #{student.forename}"
      titles[:email]= student.email
      titles[:matriculation_number] = student.matriculation_number
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
    evaluation = data.evaluation_for_student_group_and_rating(student_group, rating) || Evaluation.new_from_rating(rating)
    submission = data.submission_for_student_group(student_group)

    url = exercise_evaluation_path(@exercise, format: :js)
    html_options = {class: "exercise-evaluations-table-form", id: exercise_evaluations_form_id(student_group, rating)}

    simple_form_for(evaluation, as: :evaluation, url: url, html: html_options, remote: true) do |f|
      rc = ""
      rc << evaluation_input_field(f)
      rc << hidden_field_tag(:rating_id,        rating.id)
      rc << hidden_field_tag(:student_group_id, student_group.id)
      rc.html_safe
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

  def exercise_evaluations_create_submission_button(data, student_group)
    if data.submission_for_student_group(student_group).present?
      link_to 'Show', submission_path(data.submission_for_student_group(student_group)), class: 'tiny success button'
    else
      confirm_message = "Are sure you want to create this #{data.exercise.group_submission? ? "group" : "student"}'s submission?"
      link_to 'Create', '#', class: "tiny button exercise-evaluations-table-create-submission", data: {student_group_id: student_group.id, url: exercise_evaluation_path(@exercise), confirm: confirm_message}
    end
  end

  def evaluation_input_field(f)
    rating = f.object.rating

    f.input_field(:value, evaluation_input_field_options(rating))
  end

  def evaluation_input_field_options(rating)
    options = {}

    if rating.is_a? BinaryRating
      options[:as] = :boolean
      options[:data] = {customforms: 'disabled'}
      options[:class] = 'no-margin'
    elsif rating.is_a? ValueNumberRating
      options[:type] = :number
      options[:step] = 1
      options[:min] = rating.min_value
      options[:max] = rating.max_value
    elsif rating.is_a? ValuePercentRating
      options[:type] = :number
      options[:step] = 5
      options[:min] = rating.min_value
      options[:max] = rating.max_value
    end
    options
  end
end
