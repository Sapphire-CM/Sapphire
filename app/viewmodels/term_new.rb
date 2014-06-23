class TermNew < Term
  attr_accessor :source_term_id

  %i(copy_elements copy_lecturer copy_exercises copy_grading_scale).each do |attribute|
    attr_accessor attribute

    define_method "#{attribute}?" do
      !self.send(attribute).to_i.zero?
    end
  end
end
