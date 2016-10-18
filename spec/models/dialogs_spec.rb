describe Dialog do
  let( :user   ){ create :user  }
  let( :skill  ){ create :skill, user: user }
  let( :intent ){ create :intent, skill: skill }

  specify 'Array with non-empty string should be valid' do
    expect(
      FactoryGirl.build( :dialog, response: ["abc"], intent_id: intent )
    ).to be_valid
  end

  specify 'Empty array should not be valid' do
    expect(
      FactoryGirl.build( :dialog, response: [], intent_id: intent )
    ).to_not be_valid
  end

  specify 'Empty string in array should not be valid' do
    expect(
      FactoryGirl.build( :dialog, response: [""], intent_id: intent )
    ).to_not be_valid
  end

  specify '"nil" in array should not be valid' do
    expect(
      FactoryGirl.build( :dialog, response: [nil], intent_id: intent )
    ).to_not be_valid
  end

  specify "Set of empty strings and nill's in array should not be valid" do
    expect(
      FactoryGirl.build( :dialog, response: [nil, '', '', nil, '', ''], intent_id: intent )
    ).to_not be_valid
  end
end
