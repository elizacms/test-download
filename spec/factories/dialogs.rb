FactoryGirl.define do
  factory :dialog do
    priority 90
    unresolved []
    missing [ 'A missing rule' ]
    awaiting_field [ 'destination' ]
    intent_id intent.name
  end
end
