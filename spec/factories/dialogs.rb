FactoryGirl.define do
  factory :dialog do
    response 'What time would you like to set it for?'
    awaiting_field 'destination'
    intent_id intent
  end
end
