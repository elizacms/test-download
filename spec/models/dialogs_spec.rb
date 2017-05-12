describe Dialog do
  let!( :skill  ){ create :skill }
  let!( :valid_intent ){{
    "name"           => "valid_intent",
    "description"    => "some description",
    "mturk_response" => "some response"
  }}
  let!( :intent ){ skill.intents.create!(valid_intent) }
  let!( :dialog_params ){{
    'intent_id'      => intent.id.to_s,
    'priority'       => 100,
    'awaiting_field' => ['await'],
    'missing'        => ['miss'],
    'unresolved'     => ['no_resolve'],
    'present'        => ['here i am'],
    'entity_values'  => ['beings'],
    'comments'       => 'say something'
  }}
  let( :dialog_from_db ){ Dialog.last }


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

    specify 'Success from entity_values' do
      expect(
        FactoryGirl.build(
          :dialog,
          intent_id: intent.name,
          entity_values: ['some','thing']
        )
      ).to be_valid
    end
  end

  describe '#create' do
    it 'should create a dialog' do
      intent.dialogs.create!(dialog_params)

      expect( Dialog.count ).to eq 1
      expect( Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/dialogs/*.json"].count ).to eq 1
    end

    it 'should create two dialogs' do
      intent.dialogs.create!(dialog_params)
      intent.dialogs.create!(dialog_params)

      expect( Dialog.count ).to eq 2
      expect( Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/dialogs/*.json"].count ).to eq 2
    end
  end

  describe '#attrs', :focus do
    it 'should return a hash of attributes' do
      dialog = intent.dialogs.create!(dialog_params)

      expect( Dialog.count ).to eq 1
      ap dialog.attrs

      # Need to investigate this
      # expect( dialog.attrs['intent_id']['$oid'] ).to eq dialog.id.to_s

      expect( dialog.attrs['priority']          ).to eq 100
      expect( dialog.attrs['awaiting_field']    ).to eq ['await']
      expect( dialog.attrs['missing']           ).to eq ['miss']
      expect( dialog.attrs['unresolved']        ).to eq ['no_resolve']
      expect( dialog.attrs['present']           ).to eq ['here i am']
      expect( dialog.attrs['entity_values']     ).to eq ['beings']
      expect( dialog.attrs['comments']          ).to eq 'say something'
    end
  end

  describe '#update', :focus do
    it 'should update a field' do
      dialog = intent.dialogs.create!(dialog_params)
      dialog.update('present' => ['beyond classification'])

      expect(Dialog.count).to eq 1
      expect(Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/dialogs/*.json"].count).to eq 1

      expect( dialog_from_db.priority      ).to eq nil
      expect( dialog_from_db.missing       ).to eq nil
      expect( dialog_from_db.unresolved    ).to eq nil
      expect( dialog_from_db.present       ).to eq nil
      expect( dialog_from_db.entity_values ).to eq nil
      expect( dialog_from_db.comments      ).to eq nil


      expect( dialog.attrs['priority']      ).to eq 100
      expect( dialog.attrs['missing']       ).to eq ['miss']
      expect( dialog.attrs['unresolved']    ).to eq ['no_resolve']
      expect( dialog.attrs['present']       ).to eq ['beyond classification']
      expect( dialog.attrs['entity_values'] ).to eq ['beings']
      expect( dialog.attrs['comments']      ).to eq 'say something'
    end
  end

  describe '#destroy', :focus do
    it 'should succeed' do
      dialog = intent.dialogs.create!(dialog_params)
      expect(Dialog.count).to eq 1
      dialog_id = Dialog.last.id

      dialog.destroy

      expect( Dialog.count ).to eq 0
      expect( File.exist?("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/dialogs/#{dialog_id}.json") ).to eq false
      expect( Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/dialogs/*.json"].count ).to eq 0
    end
  end
end
