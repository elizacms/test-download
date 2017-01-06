describe Skill do
  let!( :skill  ){ create :skill }
  let!( :intent ){ create :intent, skill: skill }

  specify 'Destroy callbacks' do
    expect( Intent.count ).to eq 1
    expect( Skill.count ).to eq 1

    skill.destroy

    expect( Skill.count ).to eq 0
    expect( Intent.count ).to eq 0
  end

  specify 'Name should be unique' do
    expect( FactoryGirl.build( :skill ) ).to_not be_valid
  end

  specify 'Webhook should be unique' do
    FactoryGirl.create( :skill, name: 'Fun Times', web_hook: 'http://a.si/te' )

    expect(
      FactoryGirl.build( :skill, name: 'Run Times', web_hook: 'http://a.si/te' )
    ).to_not be_valid
  end
end
