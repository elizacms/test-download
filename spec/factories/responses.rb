FactoryGirl.define do
  factory :response do
    response_trigger "some_trigger"
    response_type "some_type"
    response_value( {text: "where would you like to go?"}.to_json )
    dialog
  end
end
