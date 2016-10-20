describe Skill do
  let!( :user   ){ create :user }
  let!( :skill  ){ create :skill, user: user }
  let!( :intent ){ create :intent, skill: skill }

  specify 'Destroy callbacks' do
    expect( Intent.count ).to eq 1
    expect( Skill.count ).to eq 1

    skill.destroy

    expect( Skill.count ).to eq 0
    expect( Intent.count ).to eq 0
  end

  specify 'Name should be unique' do
    expect( FactoryGirl.build( :skill, user: user ) ).to_not be_valid
  end

  specify 'Webhook should be unique' do
    FactoryGirl.create( :skill, user: user, name: 'Fun Times', web_hook: 'http://a.si/te' )

    expect(
      FactoryGirl.build( :skill, user: user, name: 'Run Times', web_hook: 'http://a.si/te' )
    ).to_not be_valid
  end
end
