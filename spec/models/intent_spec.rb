describe Intent, :focus do
  let(:valid_intent){{
    "name"           => "valid_intent",
    "description"    => "some description",
    "mturk_response" => "some response"
  }}

  describe '#create' do
    it 'should save a valid intent' do
      Intent.create(valid_intent)

      expect(File.exist?('spec/shared/intents/valid_intent.json')).to eq true
      expect(IntentManager.find('valid_intent')['mturk_response']).to eq 'some response'

      File.delete('spec/shared/intents/valid_intent.json')

      expect(Intent.count).to eq 1
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
end
