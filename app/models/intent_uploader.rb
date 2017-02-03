class IntentUploader
  class <<self
    include UsersHelper

    def parse_and_create( data, user )
      if data['id'].blank?
        return 'Cannot create an Intent without an ID.'
      end

      if data['skill_id'].blank? || !Skill.find_by(id: data['skill_id'])
        return 'Cannot create an Intent without a skill.'
      end

      unless user.has_role?('admin')
        return 'You do not have permission to upload intents for that skill.'
      end

      if Intent.find_by(name: data['id'])
        return 'Intent already exists.'
      end

      intent = Intent.create(
        name: data['id'],
        skill_id: data['skill_id'],
        mturk_response: data['mturk_response_fields']
      )

      data['fields'].try(:each_pair) do |k,v|
        Field.create(
          name: v['id'],
          type: v['type'],
          mturk_field: v['mturk_field'],
          intent_id: intent.id
        )
      end

      return "Intent '#{intent.name}' has been uploaded."
    end
  end
end
