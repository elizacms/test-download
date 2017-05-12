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

  describe '::find(id)' do
    it 'where id exists' do
      expect( IntentManager.find('intent2') ).to eq(
        {
          "name"           => "intent2",
          "description"    => "Another test description",
          "mturk_response" => "Training data galore"
        }
      )
    end

    it 'where id does not exist' do
      expect( IntentManager.find('never_gonna_exist') ).to eq( nil )
    end
  end
end
