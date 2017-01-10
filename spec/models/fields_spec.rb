describe Field do
  let!( :skill  ){ create :skill }
  let!( :intent ){ create :intent, skill: skill }

  specify 'id should be unique' do
    FactoryGirl.create( :field, intent: intent )

    expect( FactoryGirl.build( :field, intent: intent ) ).to_not be_valid
  end
end
