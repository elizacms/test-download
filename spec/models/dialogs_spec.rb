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
  let(  :dialog_from_db ){ Dialog.last }
  let(  :dialogs_path   ){ "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/dialogs/*.json" }
  let!( :dialog         ){ intent.dialogs.create!(dialog_params) }


  describe 'Dialogs' do
    specify 'Creating with factory saves to file system' do
      dialog = FactoryGirl.create(:dialog, intent_id: intent.id)

      expect(dialog).to be_valid
      expect(Dialog.count).to eq 2
      expect(Dir[dialogs_path].count).to eq 2
      expect(dialog.attrs[:priority]).to eq 90
    end

    specify 'Array with non-empty string should be valid' do
      expect(
        FactoryGirl.build( :dialog, awaiting_field: ['abc'], missing: ['abc'], intent_id: intent.id )
      ).to be_valid
    end

    specify 'Success from missing' do
      expect(
        FactoryGirl.build( :dialog, intent_id: intent.id, missing: ['Something here.'] )
      ).to be_valid
    end

    specify 'Success from unresolved' do
      expect(
        FactoryGirl.build( :dialog, intent_id: intent.id, unresolved: ['Something here.'] )
      ).to be_valid
    end

    specify 'Success from present' do
      expect(
        FactoryGirl.build( :dialog, intent_id: intent.id, present: ['Something here.'] )
      ).to be_valid
    end

    specify 'Success from entity_values' do
      expect(
        FactoryGirl.build( :dialog, intent_id: intent.id, entity_values: ['some','thing'] )
      ).to be_valid
    end
  end

  describe '#create' do
    it 'should create a dialog' do
      expect( Dialog.count ).to eq 1
      expect( Dir[dialogs_path].count ).to eq 1
    end

    it 'should create two dialogs' do
      intent.dialogs.create!(dialog_params)

      expect( Dialog.count ).to eq 2
      expect( Dir[dialogs_path].count ).to eq 2
    end
  end

  describe '#save' do
    specify 'is idempotent' do
      expect( dialog.attrs[ :priority ] ).to eq 100

      dialog.save
      expect( dialog.attrs[ :priority ] ).to eq 100
    end

    specify 'is idempotent with accepts_nested_attributes' do
      field = FactoryGirl.create(:field, intent: intent)
      
      dialog = Dialog.create({
        intent_id:      intent.id.to_s,
        priority:       90,
        unresolved:     [ 'unresolved' ],
        missing:        [ field.attrs[:name] ],
        present:        [ 'present', 'value' ],
        awaiting_field: [ field.attrs[:name] ],
        entity_values:  [ 'some', 'value' ],
        comments:       'some comments',
        responses_attributes: [
          response_value:   {text: 'some text'},
          response_trigger: 'some_trigger',
          response_type:    'some_type'
        ]
      })

      # puts dialog.id

      expect( dialog.attrs[ :priority ] ).to eq 90

      dialog.save
      expect( dialog.attrs[ :priority ] ).to eq 90
    end

    specify 'does not save attribute in DB' do
      expect( dialog.attrs[ :priority ] ).to eq 100

      dialog.save
      expect( dialog_from_db.priority ).to be_nil
    end
  end

  describe '#attrs' do
    it 'should return a hash of attributes' do
      expect( Dialog.count ).to eq 1

      # Need to investigate this
      # expect( dialog.attrs[:intent_id]['$oid'] ).to eq dialog.id.to_s

      expect( dialog.attrs[:priority]          ).to eq 100
      expect( dialog.attrs[:awaiting_field]    ).to eq ['await']
      expect( dialog.attrs[:missing]           ).to eq ['miss']
      expect( dialog.attrs[:unresolved]        ).to eq ['no_resolve']
      expect( dialog.attrs[:present]           ).to eq ['here i am']
      expect( dialog.attrs[:entity_values]     ).to eq ['beings']
      expect( dialog.attrs[:comments]          ).to eq 'say something'
    end
  end

  describe '#update' do
    before do
      dialog.update('present' => ['beyond classification'])
    end

    it 'should update the model in memory' do
      expect( Dir[dialogs_path].count      ).to eq 1
      expect( dialog.attrs[:priority]      ).to eq 100
      expect( dialog.attrs[:missing]       ).to eq ['miss']
      expect( dialog.attrs[:unresolved]    ).to eq ['no_resolve']
      expect( dialog.attrs[:present]       ).to eq ['beyond classification']
      expect( dialog.attrs[:entity_values] ).to eq ['beings']
      expect( dialog.attrs[:comments]      ).to eq 'say something'
    end

    it 'should not update the mongo db with attrs' do
      expect( Dialog.count                 ).to eq 1
      expect( dialog_from_db.priority      ).to eq nil
      expect( dialog_from_db.missing       ).to eq nil
      expect( dialog_from_db.unresolved    ).to eq nil
      expect( dialog_from_db.present       ).to eq nil
      expect( dialog_from_db.entity_values ).to eq nil
      expect( dialog_from_db.comments      ).to eq nil
    end
  end

  describe '#destroy' do
    it 'should succeed' do
      expect( Dialog.count ).to eq 1
      dialog_id = Dialog.last.id
      expect( File.exist?("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/dialogs/#{dialog_id}.json") ).to eq true

      dialog.destroy

      expect( Dialog.count ).to eq 0
      expect( File.exist?("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/dialogs/#{dialog_id}.json") ).to eq false
      expect( Dir[dialogs_path].count ).to eq 0
    end
  end

  describe 'long term persistence' do
    before do
      dialog.save
    end

    specify do
      expect( dialog_from_db.attrs[:priority]).to eq 100
    end
  end
end
