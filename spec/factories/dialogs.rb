FactoryGirl.define do
  factory :dialog do
    priority 90
    response [ 'Where would you like to go?' ]
    missing [ 'A missing rule' ]
    awaiting_field 'destination'
    intent_id intent.name
  end
end
