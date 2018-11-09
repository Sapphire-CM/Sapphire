class GradingScale::Bulk
  include ActiveModel::Model

  attr_accessor :grading_scale_attributes, :term

  delegate :grading_scales, to: :term

  def save
    normalized_grading_scale_attributes.map do |attributes|
      grading_scale = grading_scales.find_by(id: attributes.delete(:id))

      grading_scale.update(attributes) if grading_scale
    end.all?
  end

  def errors
    grading_scales.map(&:errors)
  end

  private

  def normalized_grading_scale_attributes
    case grading_scale_attributes
    when Array then grading_scale_attributes
    when Hash then grading_scale_attributes.values
    else
      grading_scale_attributes
    end
  end
end