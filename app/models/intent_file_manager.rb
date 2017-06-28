class IntentFileManager
  def file_path intent
    "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/eliza_de/actions/#{intent.name.downcase}.action"
  end

  def save intent, fields
    File.write( file_path(intent), intent.action_file( fields ) )
  end

  def load_intent_from file
    # skill_name = File.basename(file).split('_')[0]
    # skill = Skill.find_by_name(skill_name)
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
    File.delete( file_path(intent) )
  end
end
