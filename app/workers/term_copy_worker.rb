class TermCopyWorker
  include Sidekiq::Worker

  def perform(term_id, source_term_id, options)
    term = Term.find(term_id)
    source_term = term.course.terms.find(source_term_id)

    TermCopyingService.new(term, source_term, options.with_indifferent_access).perform!
  end
end