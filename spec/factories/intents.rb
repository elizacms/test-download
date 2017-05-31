FactoryGirl.define do
  factory :intent do
    name 'get_ride'
    description 'Get me a ride from Uber.'
    mturk_response 'uber.get.ride'
    skill
  end
end
