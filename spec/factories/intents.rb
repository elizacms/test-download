FactoryGirl.define do
  factory :intent do
    name 'get_ride'
    description 'Get me a ride from Uber.'
    mturk_response 'uber.get.ride'
    skill

    after(:create) do |intent, evaluator|
      data = {
        name: evaluator.name,
        description: evaluator.description,
        mturk_response: evaluator.mturk_response
      }.to_json

      File.write("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/#{intent.id.to_s}.json", data)
    end
  end
end
