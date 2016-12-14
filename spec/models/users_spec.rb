describe User do
  let!( :user  ){ create :user  }
  let!( :skill ){ create :skill }

  specify '#set_role admin creates Role' do
    user.set_role :admin

    expect( User.find( user ).roles.pluck( :name )).to eq [ 'admin' ]
  end

  specify '#set_role admin' do
    user.set_role :admin

    expect( user.get_roles ).to eq [{ name:'admin' }]
  end

  specify '#set_role owner' do
    user.set_role :owner, skill.name

    expect( user.get_roles ).to eq [{ name:'owner', skill:skill.name }]
  end

  specify '#set_role developer' do
    user.set_role :developer, skill.name

    expect( user.get_roles ).to eq [{ name:'developer', skill:skill.name }]
  end

  specify '#has_role for developer' do
    user.set_role :developer, skill.name

    expect( user.has_role?( :developer, skill.name )).to eq true
    expect( user.has_role?( :owner,     skill.name )).to eq false
  end

  specify '#has_role for admin' do
    user.set_role :admin

    expect( user.has_role?( :admin )).to eq true
    expect( user.has_role?( :owner, skill.name )).to eq false
  end

  specify '#remove_role for developer' do
    user.set_role :developer, skill.name
    expect( user.has_role?( :developer, skill.name )).to eq true

    user.remove_role :developer, skill.name
    expect( user.has_role?( :developer, skill.name )).to eq false
  end

  specify '#remove_role for admin' do
    user.set_role :admin
    expect( user.has_role?( :admin )).to eq true

    user.remove_role :admin
    expect( user.has_role?( :admin )).to eq false
  end
end
