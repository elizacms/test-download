FactoryGirl.define do
  factory :intent do
    name 'get_ride'
    description 'Get me a ride from Uber.'
    web_hook 'https://skills.i.am/uber'
  end
end
