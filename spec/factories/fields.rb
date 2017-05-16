FactoryGirl.define do
  factory :field do
    name 'destination'
    type 'Text'
    mturk_field 'Uber.Destination'

    after(:create) do |field, evaluator|
      data = {
        name: evaluator.name,
        type: evaluator.type,
        mturk_field: evaluator.mturk_field
      }.to_json

      File.write("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/fields/#{field.id.to_s}.json", data)
    end
  end
end
