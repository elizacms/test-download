FactoryGirl.define do
  factory :response do
    response_trigger "some_trigger"
    response_type "some_type"
    response_value "{\"text\":\"where would you like to go?\"}"
    dialog

    after(:create) do |response, evaluator|
      data = {
        response_trigger: evaluator.response_trigger,
        response_type: evaluator.response_type,
        response_value: evaluator.response_value
      }.to_json

      File.write("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/responses/#{response.id.to_s}.json", data)
    end
  end
end
