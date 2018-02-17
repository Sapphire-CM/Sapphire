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

  def checked(scopes, type_id)
    scopes.include?(type_id) unless !scopes.present?
  end


  private

  def create_types
    {
      "Admin" => [Events::Rating::Created, Events::Rating::Destroyed, Events::Rating::Updated, Events::RatingGroup::Created, Events::RatingGroup::Destroyed, Events::RatingGroup::Updated],
      "Student Groups" => [Events::StudentGroup::Updated],
      "Submissions" => [Events::Submission::Created, Events::Submission::Updated, Events::Submission::Extracted, Events::Submission::ExtractionFailed],
      "Results" => [Events::ResultPublication::Concealed, Events::ResultPublication::Published]
    }
  end
end