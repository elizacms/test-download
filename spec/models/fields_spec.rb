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
  let(:field_from_db){ Field.last }
  let!(:intent){ skill.intents.create!(intent_params) }
  let!(:field ){ intent.entities.create!(valid_field) }

  specify 'id(name) should be unique' do
    FactoryGirl.create( :field, intent: intent )

    expect( FactoryGirl.build( :field, intent: intent ) ).to_not be_valid
  end

  describe '#create' do
    it 'should create a field' do
      expect(Field.count).to eq 1
      expect(Dir[fields_path].count).to eq 1
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

      expect(Field.count).to eq 0
      expect(File.exist?(intent_file(file_id))).to eq false
      expect( Dir[fields_path].count ).to eq 0
    end
  end
end
