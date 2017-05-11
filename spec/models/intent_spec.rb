describe Intent, :focus do
  let(:valid_intent){{
    "name"           => "valid_intent",
    "description"    => "some description",
    "mturk_response" => "some response"
  }}
  let( :skill          ){ create :skill }
  let( :intent_from_db ){ Intent.first  }
  let( :read_file      ){ JSON.parse(File.read(intent_file(Intent.last.id))) }

  describe '#create' do
    it 'should save a valid intent' do
      skill.intents.create!(valid_intent)

      expect(Intent.count).to eq 1

      expect(File.exist?(intent_file(Intent.last.id))).to eq true
      expect((read_file)['mturk_response']).to eq 'some response'

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

      expect((read_file)['description']).to eq 'updated description'
      expect((read_file)['name']).to eq 'valid_intent'
      expect((read_file)['mturk_response']).to eq 'some response'
    end
  end
end
