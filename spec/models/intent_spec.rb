describe Intent, :focus do
  let(:valid_intent){{
    "name"           => "valid_intent",
    "description"    => "some description",
    "mturk_response" => "some response"
  }}
  let( :intent_file    ){ "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/valid_intent.json" }
  let( :non_file       ){ "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/.json"             }
  let( :skill          ){ create :skill                                                  }
  let( :intent_from_db ){ Intent.first                                                   }

  describe '#create' do
    it 'should save a valid intent' do
      skill.intents.create!(valid_intent)

      expect(Intent.count).to eq 1

      expect(File.exist?(intent_file)).to eq true
      expect(JSON.parse(File.read(intent_file))['mturk_response']).to eq 'some response'

      expect(intent_from_db.name).to eq nil
      expect(intent_from_db.description).to eq nil
      expect(intent_from_db.mturk_response).to eq nil
    end

    it 'should not create a duplicate intent in mongo' do
      skill.intents.create!(valid_intent)
      skill.intents.create!(valid_intent)

      expect(Intent.count).to eq 1
    end
  end

  describe '#update' do
    it 'should update a valid intent' do
      skill.intents.create!(valid_intent)
      skill.intents.first.update!('description' => 'updated description')

      expect(Intent.count).to eq 1

      expect(intent_from_db.name).to eq nil
      expect(intent_from_db.description).to eq nil
      expect(intent_from_db.mturk_response).to eq nil

      expect(JSON.parse(File.read(intent_file))['description']).to eq 'updated description'
    end
  end
end
