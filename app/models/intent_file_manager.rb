class IntentFileManager
  include FilePath

  def save intent, fields
    File.write( action_file_for(intent), intent.action_file( fields ) )
  end

  def load_intent_from file
    skill = Skill.first

    data = JSON.parse(File.read(file), symbolize_names: true)

    intent_name = data[:id]
    intent = skill.intents.find_or_create_by(name: intent_name)
    intent.update(mturk_response: data[:mturk_response_fields])

    fields = data[:fields].try(:map) do |field|
      Field.new(
        name:         field[:id],
        type:         field[:type],
        must_resolve: field[:must_resolve],
        mturk_field:  field[:mturk_field]
      )
    end

    { intent: intent, fields: fields }
  end

  def delete_file intent
    File.delete action_file_for( intent )
  end

  def fields_for intent
    intent_from_file = load_intent_from( action_file_for( intent ))
    intent_from_file[:fields]
  end

  def intent_data_for intent
    intent_from_file = load_intent_from( action_file_for( intent ))
    intent_from_file[:intent]
  end
end
