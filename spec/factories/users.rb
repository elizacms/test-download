FactoryGirl.define do
  factory :user do
    email 'user@iamplus.com'
  end

  factory :admin , class:'User' do
    email 'admin@iamplus.com'
    after( :create ){| u | u.set_role :admin }
  end
end
