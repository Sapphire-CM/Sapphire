class TermNew < Term
  attr_accessor :source_term_id

  %i(copy_elements copy_lecturer copy_exercises copy_grading_scale).each do |attribute|
    attr_accessor attribute

    define_method "#{attribute}?" do
      !send(attribute).to_i.zero?
    end
  end

  def needs_copying?
    copy_lecturer? || copy_grading_scale? || copy_exercises?
  end
end
