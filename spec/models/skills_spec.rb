describe Skill do
  let!( :skill  ){ create :skill }
  let!( :intent ){ create :intent, skill: skill }

  before do
    IntentFileManager.new.save( intent, [] )
  end

  specify 'Name should be unique' do
    expect( FactoryGirl.build( :skill ) ).to_not be_valid
  end

  specify 'Name should not contain spaces or underscores' do
    expect( Skill.create( name: 'james milani', web_hook: 'a' ) ).to_not be_valid
    expect( Skill.create( name: 'james_milani', web_hook: 'b' ) ).to_not be_valid
    expect( Skill.create( name: 'jamesmilani',  web_hook: 'c' ) ).to be_valid
  end

  specify 'Webhook should be unique' do
    FactoryGirl.create( :skill, name: 'FunTimes', web_hook: 'http://a.si/te' )

    expect(
      FactoryGirl.build( :skill, name: 'RunTimes', web_hook: 'http://a.si/te' )
    ).to_not be_valid
  end

  specify 'When skill is destroyed, should destroy associated roles' do
    user = FactoryGirl.create( :user )
    other_user = FactoryGirl.create( :user, email: 'other_user@iamplus.com' )
    FactoryGirl.create( :role, name: 'owner', skill: skill, user: user )
    FactoryGirl.create( :role, skill: skill, user: other_user )

    expect( Role.count ).to eq 2

    skill.delete

    expect( Role.count ).to eq 0
  end

  specify '::find_by_name name' do
    expect( Skill.find_by_name 'uber'  ).to eq skill
    expect( Skill.find_by_name 'Uber'  ).to eq skill
    expect( Skill.find_by_name 'henry' ).to eq nil
    expect( Skill.find_by_name nil     ).to eq nil
  end
end
