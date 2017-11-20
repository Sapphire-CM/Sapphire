class TermBasedPolicy < ApplicationPolicy
  def self.term_policy_record(term)
    raise ArgumentError.new("#{term} is not a Term") unless term.is_a? Term

    policy_record_with(term: term)
  end
end