var $table = $('.exercise-evaluations-table');

// update overall result
$table.find(".<%= exercise_evaluations_result_id(@student_group) %>").html("<%= @submission_evaluation.reload.evaluation_result %>");