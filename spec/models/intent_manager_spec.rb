describe IntentManager do
  let(:data){{
    "name"           => "intent",
    "description"    => "Some test description",
    "mturk_response" => "Some training data"
  }.to_json}
  let(:data2){{
    "name"           => "intent2",
    "description"    => "Another test description",
    "mturk_response" => "Training data galore"
  }.to_json}
  let(:data3){{
    "name"           => "intent3",
    "description"    => "Another test description",
    "mturk_response" => "Training data galore"
  }.to_json}

  before do
    File.write( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/intent.json",  data  )
    File.write( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/intent2.json", data2 )
    File.write( "#{ENV['NLU_CMS_PERSISTENCE_PATH']}/intents/intent3.json", data3 )
  end

  describe '::all' do
    it 'finds all files that end with .json' do
      expect(IntentManager.all).to eq [
        {
          "name"           => "intent",
          "description"    => "Some test description",
          "mturk_response" => "Some training data"
        },
        {
          "name"           => "intent2",
          "description"    => "Another test description",
          "mturk_response" => "Training data galore"
        },
        {
          "name"           => "intent3",
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

    it 'where name exists' do
      expect( IntentManager.find('intent2') ).to eq(
        {
          "name"           => "intent2",
          "description"    => "Another test description",
          "mturk_response" => "Training data galore"
        }
      )
    end
  end

  describe 'find_by(name)' do
    it 'if the file exists it should return the file' do
      expect( IntentManager.find_by('intent2') ).to eq(
        {
          "name"           => "intent2",
          "description"    => "Another test description",
          "mturk_response" => "Training data galore"
        }
      )
    end

    it 'if the file does not exists, it should return nil' do
      expect( IntentManager.find_by('never_gonna_exist') ).to eq( nil )
    end
  end
end
