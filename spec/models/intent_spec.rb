describe Intent do
  let(:valid_intent){{
    "name"           => "valid_intent",
    "description"    => "some description",
    "mturk_response" => "some response"
  }}
  let( :skill          ){ create :skill }
  let( :intent_from_db ){ Intent.first  }

  describe '#attrs' do
    it 'should return a hash of attributes' do
      skill.intents.create!(valid_intent)

      expect(Intent.last.attrs['name']).to eq 'valid_intent'
      expect(Intent.last.attrs['description']).to eq 'some description'
      expect(Intent.last.attrs['mturk_response']).to eq 'some response'
    end
  end

  describe '#create' do
    it 'should save a valid intent' do
      skill.intents.create!(valid_intent)

      expect(Intent.count).to eq 1

      expect(File.exist?(intent_file(Intent.last.id))).to eq true
      expect(Intent.last.attrs['mturk_response']).to eq 'some response'

      expect(intent_from_db.name).to eq nil
      expect(intent_from_db.description).to eq nil
      expect(intent_from_db.mturk_response).to eq nil
    end

    it 'should not create a intent with same name' do
      skill.intents.create(valid_intent)
      skill.intents.create(valid_intent)

      expect(Intent.count).to eq 1
    end
  end

  describe '#update' do
    it 'should update a valid intent' do
      skill.intents.create(valid_intent)

      skill.intents.first.update('description' => 'updated description')

      expect(Intent.count).to eq 1

      expect(intent_from_db.name).to eq nil
      expect(intent_from_db.description).to eq nil
      expect(intent_from_db.mturk_response).to eq nil

      expect(Intent.last.attrs['name']).to eq 'valid_intent'
      expect(Intent.last.attrs['description']).to eq 'updated description'
      expect(Intent.last.attrs['mturk_response']).to eq 'some response'

      expect( Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents"].count ).to eq 1
    end
  end

  describe '#destroy' do
    it 'should delete both the mongo intent and the FS intent' do
      skill.intents.create!(valid_intent)
      expect(Intent.count).to eq 1

      file_id = Intent.last.id

      Intent.last.destroy

      expect(Intent.count).to eq 0
      expect(File.exist?(intent_file(file_id))).to eq false
      expect( Dir["#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/*.json"].count ).to eq 0
    end
  end
end
