describe Dialog do
  let( :skill  ){ create :skill                }
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
  end
end
