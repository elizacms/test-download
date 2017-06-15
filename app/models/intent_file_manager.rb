class IntentFileManager
  def file_url intent
    "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/actions/"\
    "#{intent.skill.name.downcase}_#{intent.name.downcase}.action"
  end

  def save intent
    File.write( file_url(intent), intent.action_file )
  end

  def load_from file
    skill_name = File.basename(file).split('_')[0]
    skill = Skill.find_or_create_by(name: skill_name)

    data = JSON.parse(File.read(file), symbolize_names: true)

    intent_name = data[:id]
    intent = skill.intents.find_or_create_by(name: intent_name)
    intent.update(mturk_response: data[:mturk_response_fields])

    data[:fields].try(:each) do |field|
      field = Field.find_or_create_by(id: field[:id] )
      field.update(
        type:         field[:type],
        must_resolve: field[:must_resolve],
        mturk_field:  field[:mturk_field]
      )
    end

    intent
  end

  def delete_file intent
    File.delete( file_url(intent) )
  end
end
