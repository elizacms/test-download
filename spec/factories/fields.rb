FactoryGirl.define do
  factory :field do
    id   'set_alarm'
    type 'Boolean'
    mturk_field 'Answer.AlarmTime'
  end
end
