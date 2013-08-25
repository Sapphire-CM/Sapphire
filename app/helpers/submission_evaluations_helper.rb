module SubmissionEvaluationsHelper
  def evaluation_input_field(f)
    evaluation = f.object
    rating = evaluation.rating
    options = {}

    additional_value = nil
    if rating.is_a? BinaryRating
      options[:as] = :boolean
      options[:input_html] = { data: { customforms: 'disabled' } }
    elsif rating.is_a? ValueNumberRating
      options[:as] = :range
      options[:input_html] = {min: rating.min_value, max: rating.max_value}
      options[:step] = 1
      additional_value = evaluation.value
    elsif rating.is_a? ValuePercentRating
      options[:as] = :range
      options[:input_html] = {min: 0, max: 100}
      options[:step] = 10
      additional_value = evaluation.value
    end


    # options[:label] = "#{rating.title} (#{rating_points_description rating})"
    options[:label] = false

    f.input_field(:value, options) + raw("<span class='value'>#{additional_value}</span>")
  end
end
