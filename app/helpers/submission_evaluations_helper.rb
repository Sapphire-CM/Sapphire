module SubmissionEvaluationsHelper
  def evaluation_input_field(f)
    rating = f.object.rating
    options = {}

    if rating.is_a? BinaryRating
      options[:as] = :boolean
      options[:data] = {customforms: 'disabled'}
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

    f.input_field(:value, options)
  end
end
