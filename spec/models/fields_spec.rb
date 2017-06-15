describe Field do
  let!( :skill  ){ create :skill }
  let!( :intent_params ){{
    'name'           => 'My Intent',
    'description'    => 'A terse description',
    'mturk_response' => 'Turkey Response'
  }}
  let!( :valid_field ){{
    'name'        => 'some name',
    'type'        => 'some type',
    'mturk_field' => 'Turkey Field'
  }}
  let(:fields_path  ){ "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/fields/*.json" }
  let(:field_from_db){ Field.last                     }
  let!(:intent){ skill.intents.create!(intent_params) }
  let!(:field ){ intent.entities.create!(valid_field) }
  let!(:intent2){ create :intent, skill: skill        }
  let( :action_file_url ){ IntentFileManager.new.file_url( intent2 ) }
  let(  :file_data       ){{
    id: 'get_ride',
    fields:[
      {name: 'destination', type: 'Text', must_resolve: false , mturk_field: 'Uber.Destination'}
    ],
    mturk_response_fields: 'uber.get.ride'
  }}
  let!(:serialized_field){{
    id: field.id,
    name: 'some name',
    type: 'some type',
    mturk_field: 'Turkey Field',
    must_resolve: false
  }}

  specify 'id(name) should be unique' do
    FactoryGirl.create( :field, intent: intent )

    expect( FactoryGirl.build( :field, intent: intent ) ).to_not be_valid
  end

  describe '#save' do
    specify 'is idempotent' do
      expect( field.attrs[ :name ] ).to eq 'some name'

      field.save
      expect( field.attrs[ :name ] ).to eq 'some name'
    end

    specify 'does not save attribute in DB' do
      expect( field.attrs[ :name ] ).to eq 'some name'

      field.save
      expect( field_from_db.name ).to be_nil
    end
  end

  describe '#create' do
    it 'should create a field' do
      expect(Field.count).to eq 1
      expect(Dir[fields_path].count).to eq 1
    end

    it 'with factory saves to file system' do
      field = FactoryGirl.create(:field, intent: intent)

      expect(field).to be_valid
      expect(Field.count).to eq 2
      expect(Dir[fields_path].count).to eq 2
      expect(field.attrs[:name]).to eq 'destination'
    end
  end

  describe '#update' do
    it 'should update a field' do
      field.update('type' => 'beyond classification')

      expect(Field.count).to eq 1
      expect(Dir[fields_path].count).to eq 1

      expect(field_from_db.name).to eq nil
      expect(field_from_db.type).to eq nil
      expect(field_from_db.mturk_field).to eq nil

      expect(field.attrs[:name]).to eq 'some name'
      expect(field.attrs[:type]).to eq 'beyond classification'
      expect(field.attrs[:mturk_field]).to eq 'Turkey Field'
    end
  end

  describe '#destroy' do
    it 'should delete both the mongo field and the FS field' do
      expect(Field.count).to eq 1
      file_id = Field.last.id

      field.destroy

      expect(Field.count).to eq 1
      expect(File.exist?(intent_file(file_id))).to eq false
      expect( Dir[fields_path].count ).to eq 0
    end
  end

  describe '#serialize' do
    it 'works' do
      expect(field.serialize).to eq( serialized_field )
    end
  end

  describe 'Action File' do
    specify 'create a field and it should update the action file' do
      FactoryGirl.create( :field, intent: intent2 )
      expect( File.read( action_file_url ) ).to eq( file_data.to_json )
    end

    specify 'destroy a field and it should update the action file' do
      field = FactoryGirl.create( :field, intent: intent2 )
      field.destroy
      expect( File.read( action_file_url )).to eq( file_data.merge!(fields: []).to_json )
    end
  end
end
