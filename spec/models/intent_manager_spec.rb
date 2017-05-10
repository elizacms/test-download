describe IntentManager do

  describe '::all' do
    it 'finds all files that end with .json' do
      # file_content_1 = File.read("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/intent.json"  )
      # file_content_2 = File.read("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/intent_2.json")
      # file_content_3 = File.read("#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/intent_3.json")

      # allow(File).to receive(:read)
      # allow(JSON).to receive(:parse).exactly(3).times
      #            .and_return(
      #               JSON.parse(file_content_1),
      #               JSON.parse(file_content_2),
      #               JSON.parse(file_content_3)
      #             )

      expect(IntentManager.all).to eq [
        {
          "name"           => "intent",
          "description"    => "Some test description",
          "mturk_response" => "Some training data"
        },
        {
          "name"           => "intent_2",
          "description"    => "Another test description",
          "mturk_response" => "Training data galore"
        },
        {
          "name"           => "intent_3",
          "description"    => "Another test description",
          "mturk_response" => "Training data galore"
        }
      ]
    end
  end

  describe '::find(name)' do
    it 'raises error when name = nil' do
      expect { IntentManager.find(nil) }.to raise_error TypeError
    end

    it 'raises error when file does not exist' do
      expect { IntentManager.find('never_gonna_exist') }.to raise_error NameError
    end

    it '::find(name) where name exists' do
      expect(IntentManager.find('intent_2')).to eq(
        {
          "name"           => "intent_2",
          "description"    => "Another test description",
          "mturk_response" => "Training data galore"
        }
      )
    end
  end

  describe 'find_by(name)' do
    it 'if the file exists it should return the file' do
      expect(IntentManager.find_by('intent_2')).to eq(
        {
          "name"           => "intent_2",
          "description"    => "Another test description",
          "mturk_response" => "Training data galore"
        }
      )
    end

    it 'if the file does not exists, it should return nil' do
      expect(IntentManager.find_by('never_gonna_exist')).to eq( nil )
    end
  end
end
