class TermNew < Term

  attr_accessible :copy_elements, :source_term_id, :copy_lecturer, :copy_exercises

  def copy_elements
    @copy_elements ||= nil
  end

  def source_term_id
    @source_term_id ||= nil
  end

  def copy_lecturer
    @copy_lecturer ||= nil
  end

  def copy_exercises
    @copy_exercises ||= nil
  end


  def copy_elements=(value)
    @copy_elements = value
  end

  def source_term_id=(value)
    @source_term_id = value
  end

  def copy_lecturer=(value)
    @copy_lecturer = value
  end

  def copy_exercises=(value)
    @copy_exercises = value
  end

end