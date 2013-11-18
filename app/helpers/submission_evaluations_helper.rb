module SubmissionEvaluationsHelper
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
