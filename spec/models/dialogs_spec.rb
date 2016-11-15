describe Dialog do
  let( :user   ){ create :user                 }
  let( :skill  ){ create :skill, user: user    }
  let( :intent ){ create :intent, skill: skill }

  describe 'Missing' do
    specify 'Array with non-empty string should be valid' do
      expect(
        FactoryGirl.build(
          :dialog,
          response: 'abc',
          missing: ["abc"],
          intent_id: intent.name
        )
      ).to be_valid
    end

    specify 'Empty array should not be valid' do
      expect(
        FactoryGirl.build(
          :dialog,
          response: 'abc',
          missing: [],
          intent_id: intent.name
        )
      ).to_not be_valid
    end

    specify 'Empty string in array should not be valid' do
      expect(
        FactoryGirl.build(
          :dialog,
          response: 'abc',
          missing: [""],
          intent_id: intent.name
        )
      ).to_not be_valid
    end

    specify '"nil" in array should not be valid' do
      expect(
        FactoryGirl.build(
          :dialog,
          response: 'abc',
          missing: [nil],
          intent_id: intent.name
        )
      ).to_not be_valid
    end

    specify "Set of empty strings and nil's in array should not be valid" do
      expect(
        FactoryGirl.build(
          :dialog,
          response: 'abc',
          missing: [nil, '', '', nil, '', ''],
          intent_id: intent.name
        )
      ).to_not be_valid
    end
  end

  describe 'Must have one rule field' do
    specify 'Success from missing' do
      expect(
        FactoryGirl.build(
          :dialog,
          intent_id: intent.name,
          missing: ['Something here.'] )
      ).to be_valid
    end

    specify 'Success from unresolved' do
      expect(
        FactoryGirl.build(
          :dialog,
          intent_id: intent.name,
          unresolved: ['Something here.']
        )
      ).to be_valid
    end

    specify 'Success from present' do
      expect(
        FactoryGirl.build(
          :dialog,
          intent_id: intent.name,
          present: ['Something here.']
        )
      ).to be_valid
    end

    specify 'Failure' do
      expect(
        FactoryGirl.build(
          :dialog,
          intent_id: intent.name,
          present: [""],
          missing: [""],
          unresolved: [""]
        )
      ).to_not be_valid
    end

    specify 'Failure from any set of multi empties' do
      expect(
        FactoryGirl.build(
          :dialog,
          intent_id: intent.name,
          present: ["", nil],
          missing: ["", "", nil],
          unresolved: [nil, "", nil]
        )
      ).to_not be_valid
    end
  end
end
