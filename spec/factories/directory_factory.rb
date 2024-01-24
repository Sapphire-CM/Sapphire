FactoryBot.define do
  factory :submission_structure_directory, class: SubmissionStructure::Directory do
    name { "ExampleDirectory" }
    transient do
      nodes { {} } # Default to an empty hash
    end

    after(:build) do |directory, evaluator|
      # Check if there are any nodes
      if evaluator.nodes.present?
        # Set nodes for the directory
        evaluator.nodes.each do |node_name, node_object|
          directory << node_object
          node_object.parent = directory
        end
      end
    end


    initialize_with do
      new(name)
    end
  end
end
