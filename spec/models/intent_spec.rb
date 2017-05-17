describe Intent do
  let(:valid_intent){{
    "name"           => "valid_intent",
    "description"    => "some description",
    "mturk_response" => "some response"
  }}
  let(  :skill          ){ create :skill }
  let(  :intent_from_db ){ Intent.first  }
  let!( :intent         ){ skill.intents.create!(valid_intent) }
  let(  :intents_path   ){ "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/*.json" }

  describe '::find_by_name(name)' do
    it 'should find the intent by name' do
      expect( Intent.find_by_name( 'valid_intent' ).attrs[:description]).to eq 'some description'
    end
  end

  describe '#attrs' do
    it 'should return a hash of attributes' do
      expect(Intent.last.attrs[:name]).to eq 'valid_intent'
      expect(Intent.last.attrs[:description]).to eq 'some description'
      expect(Intent.last.attrs[:mturk_response]).to eq 'some response'
    end
  end

  describe '#create' do
    it 'should save a valid intent' do
      expect(Intent.count).to eq 1

      expect(File.exist?(intent_file(Intent.last.id))).to eq true
      expect(Intent.last.attrs[:mturk_response]).to eq 'some response'

      expect(intent_from_db.name).to eq nil
      expect(intent_from_db.description).to eq nil
      expect(intent_from_db.mturk_response).to eq nil
    end

    it 'should not create a intent with same name' do
      skill.intents.create(valid_intent)
      skill.intents.create(valid_intent)

      expect(Intent.count).to eq 1
    end

    it 'with factory saves to file system' do
      intent = FactoryGirl.create(:intent, skill: skill)

      expect(intent).to be_valid
      expect(Intent.count).to eq 2
      expect(Dir[intents_path].count).to eq 2
      expect(intent.attrs[:name]).to eq 'get_ride'
    end
  end

  describe '#update' do
    it 'should update a valid intent' do
      skill.intents.first.update('description' => 'updated description')

      expect(Intent.count).to eq 1

      expect(intent_from_db.name).to eq nil
      expect(intent_from_db.description).to eq nil
      expect(intent_from_db.mturk_response).to eq nil

      expect(Intent.last.attrs[:name]).to eq 'valid_intent'
      expect(Intent.last.attrs[:description]).to eq 'updated description'
      expect(Intent.last.attrs[:mturk_response]).to eq 'some response'

      expect( Dir[intents_path].count ).to eq 1
    end
  end

  describe '#destroy' do
    it 'should delete both the mongo intent and the FS intent' do
      expect(Intent.count).to eq 1

      file_id = Intent.last.id

      Intent.last.destroy

      expect(Intent.count).to eq 0
      expect(File.exist?(intent_file(file_id))).to eq false
      expect( Dir[intents_path].count ).to eq 0
    end
  end
end
