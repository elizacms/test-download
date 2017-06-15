class IntentUploader
  class <<self
    include UsersHelper

    def parse_and_create( data, user )
      if data['id'].blank?
        return 'Cannot create an Intent without a name.'
      end

      if data['skill_id'].blank? || !Skill.find_by(id: data['skill_id'])
        return 'Cannot create an Intent without a skill.'
      end

      unless user.has_role?('admin')
        return 'You do not have permission to upload intents for that skill.'
      end

      intent_names = Intent.all_files.map do |file|
        JSON.parse(File.read(file), symbolize_names: true)[:name]
      end

      if intent_names.include? data['id']
        return 'Intent already exists.'
      end

      intent = Skill.find(id: data['skill_id']).intents.create(
        name: data['id'],
        mturk_response: data['mturk_response_fields']
      )

      data['fields'].try(:each_pair) do |k,v|
        intent.entities.create(
          name: v['id'],
          type: v['type'],
          mturk_field: v['mturk_field']
        )
      end

      return "Intent '#{intent.name}' has been uploaded."
    end
  end
end
