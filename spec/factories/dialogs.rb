FactoryGirl.define do
  factory :dialog do
    priority 90
    unresolved []
    missing [ 'A missing rule' ]
    awaiting_field [ 'destination' ]
    intent_id intent
    entity_values ['some','thing']
    comments 'some comment'

    after(:create) do |dialog, evaluator|
      data = {
        priority: evaluator.priority,
        unresolved: evaluator.unresolved,
        missing: evaluator.missing,
        awaiting_field: evaluator.awaiting_field,
        entity_values: evaluator.entity_values,
        comments: evaluator.comments
      }.to_json

      File.write("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/dialogs/#{dialog.id.to_s}.json", data)
    end
  end
end
