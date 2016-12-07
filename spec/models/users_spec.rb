describe User do
  let!( :user  ){ create :user  }
  let!( :skill ){ create :skill }

  specify 'Set Admin Role' do
    user.set_role :admin

    expect( User.find( user ).roles.pluck( :name )).to eq [ 'admin' ]
  end

  specify 'Set Skill Owner Role' do
    user.set_role :owner, skill.name

    expect( user.get_roles ).to eq [{ name:'owner', skill:skill.name }]
  end

  specify 'Set Skill Developer Role' do
    user.set_role :developer, skill.name

    expect( user.get_roles ).to eq [{ name:'developer', skill:skill.name }]
  end

  specify '#has_role' do
    user.set_role :developer, skill.name

    expect( user.has_role?( :developer, skill.name )).to eq true
    expect( user.has_role?( :owner,     skill.name )).to eq false
  end

  specify '#remove_role' do
    user.set_role :developer, skill.name
    expect( user.has_role?( :developer, skill.name )).to eq true

    user.remove_role :developer, skill.name
    expect( user.has_role?( :developer, skill.name )).to eq false
  end
end
