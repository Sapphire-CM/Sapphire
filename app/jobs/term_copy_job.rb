class TermCopyJob < ActiveJob::Base
  queue_as :default

  def perform(term_id, source_term_id, options)
    term = Term.find(term_id)
    source_term = term.course.terms.find(source_term_id)

    TermCopyService.new(term, source_term, options.with_indifferent_access).perform!
  end
end
