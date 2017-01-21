class IntentUploader
  class <<self
    def parse_and_create( data )
      if data['id'].blank?
        return { notice: 'Cannot create an Intent without an ID.' }
      end

      if data['skill_id'].blank? || !Skill.find_by(id: data['skill_id'])
        return { notice: 'Cannot create an Intent without a skill.' }
      end

      if Intent.find_by(name: data['id'])
        return { notice: 'Intent already exists.' }
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

      return { notice: "Intent '#{intent.name}' has been uploaded." }
    end
  end
end
