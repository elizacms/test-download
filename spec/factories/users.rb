FactoryGirl.define do
  factory :user do
    email 'user@iamplus.com'
  end

  factory :admin , class:'User' do
    email 'admin@iamplus.com'
    after( :create ){| u | u.set_role :admin }
  end

  factory :developer , class:'User' do
    email 'developer@iamplus.com'
    after( :create ){| u | u.set_role :developer }
  end
end
