FactoryGirl.define do
  factory :dialog do
    response [ 'Where would you like to go?' ]
    awaiting_field 'destination'
    intent_id intent.name
  end
end
