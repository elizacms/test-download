describe Intent do
  let(:valid_intent){{
    "name"           => "valid_intent",
    "description"    => "some description",
    "mturk_response" => "some response"
  }}
  let(:intent_file){"#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/valid_intent.json"}
  let(:skill){ create :skill}
  let(:intent_from_db){Intent.first}

  describe '#create' do
    it 'should save a valid intent', :focus do
      skill.intents.create!(valid_intent)

      expect(Intent.count).to eq 1

      expect(File.exist?(intent_file)).to eq true
      expect(JSON.parse(File.read(intent_file))['mturk_response']).to eq 'some response'

      expect(intent_from_db.name).to eq nil
      expect(intent_from_db.description).to eq nil
      expect(intent_from_db.mturk_response).to eq nil
    end

    it 'should not save an invalid intent' do
      Intent.create(valid_intent.merge!('name' => ''))

      expect(File.exist?('spec/shared/intents/.json')).to eq false
      expect{ IntentManager.find('valid_intent') }.to raise_error NameError

      expect(Intent.count).to eq 0
    end
  end

  describe '#update' do
  end

  describe '#save' do

  end
end
