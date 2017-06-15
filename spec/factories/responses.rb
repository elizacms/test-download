FactoryGirl.define do
  factory :response do
    response_trigger({trigger: "some_trigger"}.to_json)
    response_type "some_type"
    response_value( {text: "where would you like to go?"}.to_json )
    dialog
  end
end
