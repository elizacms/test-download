describe Dialog do
  let( :skill  ){ create :skill                }
  let( :intent ){ create :intent, skill: skill }

  describe 'Dialogs' do
    specify 'Array with non-empty string should be valid' do
      expect(
        FactoryGirl.build(
          :dialog,
          awaiting_field: ['abc'],
          missing: ['abc'],
          intent_id: intent.name
        )
      ).to be_valid
    end

    specify do
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
