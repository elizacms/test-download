FactoryGirl.define do
  factory :question, class:FAQ::Question do
    text 'What is wrong with my phone?'
    is_faq false
  end
end