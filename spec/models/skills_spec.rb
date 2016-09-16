describe Skill do
  let!( :user   ){ create :user }
  let!(  :skill  ){ create :skill, user: user }
  let!(  :intent ){ create :intent, skill: skill }

  specify 'Destroy callbacks' do
    expect( Intent.count ).to eq 1
    expect( Skill.count ).to eq 1

    skill.destroy

    expect( Skill.count ).to eq 0
    expect( Intent.count ).to eq 0
  end
end
