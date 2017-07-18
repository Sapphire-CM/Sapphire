class EventTypeService
  attr_reader :types

  def initialize
    @types = create_types
  end

  def types_for_scopes(scope_ids)
    types = []

    scope_ids.each do |scope_id|
      types_for_scope = @types[scope_id]

      types += types_for_scope if types_for_scope
    end

    types
  end


  private

  def create_types
    {
      "admin" => [Events::Rating::Created, Events::Rating::Updated, Events::Rating::Destroyed],
      "submissions" => [Events::Submission::Created]
    }
  end
end